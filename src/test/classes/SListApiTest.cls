@IsTest(IsParallel = true)
public class SListApiTest {
    @IsTest
    static void example() {
        List<Contact> contacts = buildContactList();

        // do some filtering and grouping of our contacts
        Map<Object, List<SObject>> result = new SListApi(contacts)
            .removeNulls('Account.Name')  // remove contacts whose account name is null
            .filter('Account.Id', CollectionUtils.FilterOperator.EQUALS, IdUtils.id(0, Account.SObjectType))  // find contacts with account id = 0
            .groupBy('LastName');  // group results by last name

        System.assertEquals(2, result.size());
        System.assert(result.keySet().contains('Test'));
        System.assert(result.keySet().contains('Test3'));

        // convert object map to concrete map
        Map<String, List<Contact>> concreteResult = new Map<String, List<Contact>>();
        for (Object key : result.keySet()) {
            concreteResult.put((String)key, (List<Contact>)result.get(key));
        }

        // convert map values into a flat list
        List<Contact> values = (List<Contact>)new ListApi(result.values())
            .flatten()
            .toList(new List<Contact> {});

        System.assertEquals(2, values.size());
        System.assertEquals(contacts[0], values[0]);
        System.assertEquals(contacts[3], values[1]);

        // group by an sobject field
        Map<Object, List<SObject>> groupResult = new SListApi(contacts)
            .groupBy('Account', true);

        System.assertEquals(3, groupResult.keySet().size());

        // convert object map to concrete map
        Map<Account, List<Contact>> concreteGroupResult = new Map<Account, List<Contact>>();
        for (Object key : groupResult.keySet()) {
            concreteGroupResult.put((Account)key, (List<Contact>)groupResult.get(key));
        }

        // pluck unique accounts from contacts
        List<Account> accounts = (List<Account>)new SListApi(contacts)
            .pluck('Account', true)
            .removeDuplicates()
            .toList();

        System.assertEquals(3, accounts.size());

        // pluck unique last names from contacts
        List<String> lastNames = (List<String>)new SListApi(contacts)
            .pluck('LastName')
            .removeDuplicates()
            .toList(new List<String> {});

        System.assertEquals(3, accounts.size());

        // get all contacts not in the second list using difference
        List<Contact> diffResult = (List<Contact>)new SListApi(contacts)
            .difference(new List<Contact> { contacts[0], contacts[1], contacts[2], new Contact(FirstName = 'new') })
            .toList();

        System.assertEquals(2, diffResult.size());
        System.assertEquals(contacts[3], diffResult[0]);
        System.assertEquals(contacts[4], diffResult[1]);

        // get all contacts that exist in both lists using intersect
        List<Contact> intersectResult = (List<Contact>)new SListApi(contacts)
            .intersect(new List<Contact> { contacts[0], contacts[1], contacts[2], new Contact(FirstName = 'new') })
            .toList();

        System.assertEquals(3, intersectResult.size());
        System.assertEquals(contacts[0], intersectResult[0]);
        System.assertEquals(contacts[1], intersectResult[1]);
        System.assertEquals(contacts[2], intersectResult[2]);

        // join two lists using union
        List<Contact> unionResult = (List<Contact>)new SListApi(contacts)
            .union(new List<Contact> { contacts[0], contacts[1], contacts[2], new Contact(FirstName = 'new') })
            .toList();

        System.assertEquals(6, unionResult.size());
        System.assertEquals(contacts[0], unionResult[0]);
        System.assertEquals(contacts[1], unionResult[1]);
        System.assertEquals(contacts[2], unionResult[2]);
        System.assertEquals(contacts[3], unionResult[3]);
        System.assertEquals(contacts[4], unionResult[4]);
        System.assertEquals('new', unionResult[5].FirstName);
    }

    @IsTest
    static void it_should_be_iterable() {
        List<Contact> contacts = buildContactList();

        SListApi myList = new SListApi(contacts);

        Iterator<SObject> iterator = myList.iterator();
        List<Contact> all = new List<Contact> {};
        while (iterator.hasNext()) {
            Contact value = (Contact)iterator.next();
            all.add(value);
        }
        System.assertEquals(5, all.size());
        System.assertEquals(contacts, all);
    }

    @IsTest
    static void it_should_group_by_string(){
        //given - list sobj
        List<Contact> contactList = buildContactList();

        //when - sort by string field
        Map<String, List<Contact>> groupedList = (Map<String, List<Contact>>)SListApi.fromList(contactList).groupByString('LastName');

        //then data grouped by string field
        System.assertEquals(2, groupedList.get('Test').size());
    }

    @IsTest
    static void it_should_group_by_id(){
         //given - list sobj
         List<Contact> contactList = buildContactList();

         //when - sort by id field
         Map<Id, List<Contact>> groupedList = (Map<Id, List<Contact>>)SListApi.fromList(contactList).groupById('AccountId');

         //then data grouped by id field
         for(Id key : groupedList.keySet()) {
             System.assert(String.valueOf(key).startsWith('001'));
         }

    }

    private static List<Contact> buildContactList() {
        return new List<Contact> {
            new Contact(FirstName = '0', LastName = 'Test', AccountId = IdUtils.id(0, Account.SObjectType), Account = new Account(Id = IdUtils.id(0, Account.SObjectType), Name = 'TestAcct'))
            , new Contact(FirstName = '1', LastName = 'Test', AccountId = IdUtils.id(1, Account.SObjectType), Account = new Account(Id = IdUtils.id(1, Account.SObjectType), Name = 'TestAcct'))
            , new Contact(FirstName = '2', LastName = 'Test2', AccountId = IdUtils.id(1, Account.SObjectType), Account = new Account(Id = IdUtils.id(1, Account.SObjectType), Name = 'TestAcct'))
            , new Contact(FirstName = '3', LastName = 'Test3', AccountId = IdUtils.id(0, Account.SObjectType), Account = new Account(Id = IdUtils.id(0, Account.SObjectType), Name = 'TestAcct'))
            , new Contact(FirstName = '4', LastName = 'Test3', AccountId = IdUtils.id(0, Account.SObjectType), Account = new Account(Id = IdUtils.id(0, Account.SObjectType)))
        };
    }
}