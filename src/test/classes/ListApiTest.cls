@IsTest(IsParallel=true)
public class ListApiTest {
    @IsTest
    static void example() {
        List<Object> aList = new List<Object>{
            null,
            1,
            2,
            new List<Object>{ 3, 4, null, new List<Object>{ 5, 6, null }, 7, null, 8 },
            9,
            10
        };

        List<Integer> result = (List<Integer>) new ListApi(aList)
            .flatten() // converts to list 1-10 with nulls
            .removeNulls() // removes nulls
            .filter(CollectionUtils.FilterOperator.GREATER_THAN, 5) // removes items <= 5
            .difference(new List<Integer>{ 3, 7, 10 }) // removes 7 and 10 because they exist in the difference list
            .union(new List<Integer>{ 8, 13, 9 }) // adds 13 because it exists in the union list
            .intersect(new List<Integer>{ 6, 1, 5, 8, 10, 13 }) // removes 9 because it does not exist in the intersect list
            .toList(new List<Integer>{}); // converts List<Object> to List<Integer> for easy casting

        System.assertEquals(new List<Integer>{ 6, 8, 13 }, result);
    }

    @IsTest
    static void it_should_be_iterable() {
        ListApi myList = new ListApi(new List<Integer>{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });

        myList.filter(CollectionUtils.FilterOperator.GREATER_THAN, 5);

        Iterator<Object> iterator = myList.iterator();
        List<Integer> all = new List<Integer>{};
        while (iterator.hasNext()) {
            Integer value = (Integer) iterator.next();
            System.assert(value > 5);
            all.add(value);
        }
        System.assertEquals(5, all.size());
        System.assertEquals(new List<Integer>{ 6, 7, 8, 9, 10 }, all);

        List<Integer> result = (List<Integer>) myList.toList(new List<Integer>{});
        System.assertEquals(all, result);
    }
}
