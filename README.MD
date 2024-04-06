# Задание:
https://github.com/rreeggeenntt4/vd/blob/main/README.pdf
# Решение:
```
docker-composer up
```
```
php artisan make:controller FlightController
```

```php

namespace App\Http\Controllers;

use DateTime;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FlightController extends Controller
{
    public function getAircraftAirports(Request $request)
    {
        $request->validate([
            'tail' => 'required|string',
            'date_from' => 'required|date',
            'date_to' => 'required|date|after_or_equal:date_from',
        ]);

        $tail = $request->input('tail');
        $date_from = $request->input('date_from');
        $date_to = $request->input('date_to');

        /* Перелетвы попадающие в указанное время от/до */
        $result = DB::select("
            SELECT flights.id, flights.aircraft_id, flights.airport_id1, flights.airport_id1, flights.airport_id1, flights.airport_id2, flights.takeoff, flights.landing, flights.cargo_load, flights.cargo_offload, airports.code_iata, airports.code_icao 
            FROM flights
            JOIN airports ON flights.airport_id1 = airports.id 
            WHERE flights.aircraft_id = (SELECT id FROM aircrafts WHERE tail = ?)
            AND (flights.takeoff BETWEEN ? AND ?
            OR flights.landing BETWEEN ? AND ?          
            )
            ORDER BY takeoff
        ", [$tail, $date_from, $date_to, $date_from, $date_to]);


        if (isset($result)) {
            if (count($result) > 0) {
                $datetime1 = new DateTime($date_from);
                $datetime2 = new DateTime($result[0]->takeoff);
                /* Проверяем что самолет находится в аэропорту */
                if ($datetime1 < $datetime2) {
                    /* Находим id предыдущего перелета */
                    $r = DB::select("
                    SELECT MAX(id)
                    FROM flights
                    WHERE flights.aircraft_id = (SELECT id FROM aircrafts WHERE tail = ?)
                    AND flights.airport_id2 = ?
                    AND flights.landing < ?", [$tail, $result[0]->airport_id1, $result[0]->takeoff]);
                    $max_prev_id = $r[0]->max;

                    /* Предыдущий перелет */
                    $result2 = DB::select("
                    SELECT flights.id, flights.aircraft_id, flights.airport_id1, flights.airport_id1, flights.airport_id1, flights.airport_id2, flights.takeoff, flights.landing, flights.cargo_load, flights.cargo_offload, airports.code_iata, airports.code_icao
                    FROM flights
                    JOIN airports ON flights.airport_id1 = airports.id 
                    WHERE flights.id = ?", [$max_prev_id]);

                    /* Добавляем элемент в начало массива е6сли он существует */
                    if (isset($result2) && count($result2) > 0) {
                        array_unshift($result, $result2[0]);
                    }
                }

                $datetime3 = new DateTime($date_to);
                /* if (is_countable($result)) { */
                $datetime4 = new DateTime($result[count($result) - 1]->landing);
                /* Если промежуток времени "до" больше времени максимального элемента массива "landing" */
                if ($datetime3 > $datetime4) {
                    /* Находим id следующего перелета */
                    $r2 = DB::select("
                        SELECT MIN(id)
                        FROM flights
                        WHERE flights.aircraft_id = (SELECT id FROM aircrafts WHERE tail = ?)
                        AND flights.airport_id1 = ?
                        AND flights.takeoff > ?", [$tail, $result[count($result) - 1]->airport_id2, $result[count($result) - 1]->landing]);
                    $min_next_id = $r2[0]->min;

                    /* Следующий перелет */
                    $result3 = DB::select("
                        SELECT flights.id, flights.aircraft_id, flights.airport_id1, flights.airport_id1, flights.airport_id1, flights.airport_id2, flights.takeoff, flights.landing, flights.cargo_load, flights.cargo_offload, airports.code_iata, airports.code_icao
                        FROM flights
                        JOIN airports ON flights.airport_id1 = airports.id 
                        WHERE flights.id = ?", [$min_next_id]);

                    /* Добавляем следукющий перелет */
                    /* Добавляем элемент в массив если он существует */
                    if (isset($result3) && count($result3) > 0) {
                        array_push($result, $result3[0]);
                    }
                }
            } else {
                /* Самолет находится в аэропорту и промежуток времени учитывает только нахождение в аэропорту без совершения полета. */

                /* Находим id предыдущего перелета */
                $r = DB::select("
                SELECT MAX(id)
                FROM flights
                WHERE flights.aircraft_id = (SELECT id FROM aircrafts WHERE tail = ?)
                AND flights.landing < ?", [$tail, $date_from]);
                $max_prev_id = $r[0]->max;

                /* Предыдущий перелет */
                $result2 = DB::select("
                SELECT flights.id, flights.aircraft_id, flights.airport_id1, flights.airport_id1, flights.airport_id1, flights.airport_id2, flights.takeoff, flights.landing, flights.cargo_load, flights.cargo_offload, airports.code_iata, airports.code_icao
                FROM flights
                JOIN airports ON flights.airport_id1 = airports.id 
                WHERE flights.id = ?", [$max_prev_id]);

                /* Добавляем элемент в начало массива если он существует */
                if (isset($result2) && count($result2) > 0) {
                    array_unshift($result, $result2[0]);
                }


                /* Находим id следующего перелета */
                $r2 = DB::select("
                SELECT MIN(id)
                FROM flights
                WHERE flights.aircraft_id = (SELECT id FROM aircrafts WHERE tail = ?)
                AND flights.airport_id1 = ?
                AND flights.takeoff > ?", [$tail, $result[count($result) - 1]->airport_id2, $result[count($result) - 1]->landing]);
                $min_next_id = $r2[0]->min;

                /* Следующий перелет */
                $result3 = DB::select("
                SELECT flights.id, flights.aircraft_id, flights.airport_id1, flights.airport_id1, flights.airport_id1, flights.airport_id2, flights.takeoff, flights.landing, flights.cargo_load, flights.cargo_offload, airports.code_iata, airports.code_icao
                FROM flights
                JOIN airports ON flights.airport_id1 = airports.id 
                WHERE flights.id = ?", [$min_next_id]);

                /* Добавляем следукющий перелет */
                array_push($result, $result3[0]);
            }
        }

        /* Массив  пребывания самолета в аэропорту. */
        $new_arr = [];

        /* Если за заданный период времени самолет стартовал с аэропорта и приземлился в аэропорт */
        for ($i = 0; $i < count($result) - 1; $i++) {
            $new_arr[$i]['airport_id'] = $result[$i]->airport_id2;
            $new_arr[$i]['code_iata'] = $result[$i]->code_iata;
            $new_arr[$i]['code_icao'] = $result[$i]->code_icao;
            $new_arr[$i]['cargo_offload'] = $result[$i]->cargo_offload;
            $new_arr[$i]['cargo_load'] = $result[$i + 1]->cargo_load;
            $new_arr[$i]['landing'] = $result[$i]->landing;
            $new_arr[$i]['takeoff'] = $result[$i + 1]->takeoff;
        }

        return response()->json($new_arr);
    }
}
```

laravel\routes\api.php
```php

use App\Http\Controllers\FlightController;

...

Route::get('/aircraft_airports', [FlightController::class, 'getAircraftAirports']);
```
---
### Заметка:
очевидно можно улучшить, например, участок
```php
if (count($result) > 0) {
    ...
}else{
    ...
}
```
 

---
Видеообзор https://youtu.be/L6X2Nyyuh2I

