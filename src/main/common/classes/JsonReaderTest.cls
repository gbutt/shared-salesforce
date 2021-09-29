@IsTest(isParallel=true)
public class JsonReaderTest {
    @IsTest
    static void it_should_return_true_when_field_exists() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'id' => '123',
            'data' => new Map<String, Object>{
                'name' => 'steve',
                'address' => new Map<String, Object>{ 'line1' => '123 Sesame St' }
            }
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals(true, jsonReader.hasField('id'));
        System.assertEquals(true, jsonReader.hasField('data.name'));
        System.assertEquals(true, jsonReader.hasField('data.address.line1'));
        System.assertEquals(false, jsonReader.hasField('data.address.line2'));
        System.assertEquals(false, jsonReader.hasField('null'));
    }

    @IsTest
    static void it_should_get_field_as_string_map() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'id' => '123',
            'data' => new Map<String, Object>{
                'name' => 'steve',
                'address' => new Map<String, Object>{ 'line1' => '123 Sesame St' }
            }
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals('123', jsonReader.getString('id'));
        System.assertEquals('steve', jsonReader.getString('data.name'));
        System.assertEquals('123 Sesame St', jsonReader.getString('data.address.line1'));
        System.assertEquals(null, jsonReader.getString('data.address.line2'));
        System.assertEquals(null, jsonReader.getString('null'));
    }

    @IsTest
    static void it_should_get_field_as_string_array() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'results' => new List<Object>{
                new Map<String, Object>{
                    'id' => '123',
                    'data' => new Map<String, Object>{
                        'name' => 'steve',
                        'address' => new Map<String, Object>{ 'line1' => '123 Sesame St' }
                    }
                }
            }
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals('123', jsonReader.getString('results[0].id'));
        System.assertEquals('steve', jsonReader.getString('results[0].data.name'));
        System.assertEquals('123 Sesame St', jsonReader.getString('results[0].data.address.line1'));
        System.assertEquals(null, jsonReader.getString('results[0].data.address.line2'));
        System.assertEquals(null, jsonReader.getString('null'));
    }

    @IsTest
    static void it_should_get_field_as_double() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'id' => 123,
            'data' => new Map<String, Object>{
                'name' => 45.6,
                'address' => new Map<String, Object>{ 'line1' => null }
            }
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals(123, jsonReader.getDouble('id'));
        System.assertEquals(45.6, jsonReader.getDouble('data.name'));
        System.assertEquals(null, jsonReader.getDouble('data.address.line1'));
        System.assertEquals(null, jsonReader.getDouble('null'));
    }

    @IsTest
    static void it_should_get_field_as_date() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'expires_at' => '2019-01-21',
            'created_at' => '2019-01-21T23:59:59.000Z',
            'created_at_2' => '2019-01-21T00:00:00.000Z',
            'null' => ''
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals(Date.newInstance(2019, 1, 21), jsonReader.getDate('expires_at'));
        // time and timezone are ignored
        System.assertEquals(Date.newInstance(2019, 1, 21), jsonReader.getDate('created_at'));
        System.assertEquals(Date.newInstance(2019, 1, 21), jsonReader.getDate('created_at_2'));
        System.assertEquals(null, jsonReader.getDate('null'));
        System.assertEquals(null, jsonReader.getDate('null2'));
    }

    @IsTest
    static void it_should_get_field_as_datetime() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'created_at' => '2019-01-21T12:31:59.000Z',
            'expires_at' => '2019-01-21 00:00:00.000-0700',
            'expires_at_2' => '2019-01-21 00:00:00.000-1400',
            'null' => ''
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals(
            DateTime.newInstanceGmt(2019, 1, 21, 12, 31, 59),
            jsonReader.getDateTime('created_at')
        );
        // timezones other than Z are ignored
        System.assertEquals(
            DateTime.newInstance(2019, 1, 21),
            jsonReader.getDateTime('expires_at')
        );
        System.assertEquals(
            DateTime.newInstance(2019, 1, 21),
            jsonReader.getDateTime('expires_at_2')
        );
        System.assertEquals(null, jsonReader.getDateTime('null'));
        System.assertEquals(null, jsonReader.getDateTime('null2'));
    }

    @IsTest
    static void it_should_get_field_as_datetime_utc() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'created_at' => '2019-01-21T12:31:59.000',
            'null' => ''
        };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals(
            DateTime.newInstanceGmt(2019, 1, 21, 12, 31, 59),
            jsonReader.getDateTimeUtc('created_at')
        );
        System.assertEquals(null, jsonReader.getDateTime('null'));
        System.assertEquals(null, jsonReader.getDateTime('null2'));
    }

    @IsTest
    static void it_should_get_field_as_boolean() {
        Map<String, Object> jsonMap = new Map<String, Object>{ 'success' => true, 'null' => null };

        JsonReader jsonReader = new JsonReader(jsonMap);

        System.assertEquals(true, jsonReader.getBoolean('success'));
        System.assertEquals(null, jsonReader.getBoolean('null'));
        System.assertEquals(null, jsonReader.getBoolean('null2'));
    }

    @IsTest
    static void it_should_get_array_field_as_string() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'test1' => new List<Object>{ 1, 2, 3 },
            'test2' => new List<Object>{ new List<Object>{ 1, 2, 3 }, new List<Object>{ 4, 5, 6 } },
            'test3' => new List<Object>{ new Map<String, Object>{ 'name' => 'seadog' } }
        };

        JsonReader jsonReader = new JsonReader(jsonMap);
        System.assertEquals(1, jsonReader.getDouble('test1[0]'));
        System.assertEquals(6, jsonReader.getDouble('test2[1][2]'));
        System.assertEquals('seadog', jsonReader.getString('test3[0].name'));
    }
}
