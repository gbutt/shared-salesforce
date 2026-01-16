@IsTest
public class CollectionUtilsTest {
    // EXAMPLES

    @IsTest
    static void example_pluck_account_ids_for_query() {
        // build ten contacts
        List<Contact> contacts = new List<Contact>(10);
        for (Integer idx = 0; idx < contacts.size(); idx++) {
            contacts[idx] = new Contact(
                Id = IdUtils.id(idx, Contact.SObjectType),
                FirstName = String.valueOf(idx),
                LastName = 'Test',
                AccountId = IdUtils.id(idx, Account.SObjectType)
            );
        }

        // pluck the Account Ids
        List<Id> accountIds = (List<Id>) CollectionUtils.pluck(contacts, 'AccountId', new List<Id>{});
        System.assertEquals(10, accountIds.size());
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :accountIds];
    }

    @IsTest
    static void example_split_contacts_by_lastname_version_1() {
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = '0', LastName = 'Test', Email = 'test'),
            new Contact(FirstName = '1', LastName = 'Test', Email = 'test'),
            new Contact(FirstName = '2', LastName = 'Test2', Email = 'test'),
            new Contact(FirstName = '3', LastName = 'Test2', Email = 'test'),
            new Contact(FirstName = '4', LastName = 'Test3', Email = 'test')
        };

        // split all contacts with lastname = Test and lastname != Test
        // 1. group by LastName
        Map<Object, List<SObject>> groupedByLastName = CollectionUtils.groupBy(contacts, 'LastName');
        // 2, get contacts with LastName = 'Test'
        List<Contact> testContacts = (List<Contact>) groupedByLastName.get('Test');
        // 3. get all contacts not in the testContacts list
        List<Contact> notTestContacts = (List<Contact>) CollectionUtils.difference(
            contacts,
            testContacts,
            new List<Contact>{}
        );

        // all contacts have LastName = Test
        System.assertEquals(2, testContacts.size());
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.LastName);
        }
        // all contacts have LastName != Test
        System.assertEquals(
            contacts.size() - testContacts.size(),
            notTestContacts.size(),
            notTestContacts
        );
        for (Contact c : notTestContacts) {
            System.assertNotEquals('Test', c.LastName);
        }
    }

    @IsTest
    static void example_split_contacts_by_lastname_version_2() {
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = '0', LastName = 'Test', Email = 'test'),
            new Contact(FirstName = '1', LastName = 'Test', Email = 'test'),
            new Contact(FirstName = '2', LastName = 'Test2', Email = 'test'),
            new Contact(FirstName = '3', LastName = 'Test2', Email = 'test'),
            new Contact(FirstName = '4', LastName = 'Test3', Email = 'test')
        };

        // another way to split all contacts with lastname = Test and lastname != Test
        // 1. group by LastName
        Map<Object, List<SObject>> groupedByLastName = CollectionUtils.groupBy(contacts, 'LastName');
        // 2. remove 'Test' entry from the map
        List<Contact> testContacts = (List<Contact>) groupedByLastName.remove('Test');
        // 3. flatten the remaining values into a list
        List<Contact> notTestContacts = (List<Contact>) CollectionUtils.flatten(
            groupedByLastName.values(),
            new List<Contact>{}
        );

        // all contacts have LastName = Test
        System.assertEquals(2, testContacts.size());
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.LastName);
        }

        // all contacts have LastName != Test
        System.assertEquals(
            contacts.size() - testContacts.size(),
            notTestContacts.size(),
            notTestContacts
        );
        for (Contact c : notTestContacts) {
            System.assertNotEquals('Test', c.LastName);
        }
    }

    @IsTest
    static void example_filter_contacts_by_date() {
        // 10 contacts with birthdays between jan 1 and jan 10
        List<Contact> contacts = new List<Contact>(10);
        for (Integer idx = 0; idx < contacts.size(); idx++) {
            contacts[idx] = new Contact(
                Id = IdUtils.id(idx, Contact.SObjectType),
                BirthDate = Date.newInstance(2000, 1, idx + 1)
            );
        }

        Date filterDate = Date.newInstance(2000, 1, 5);
        List<Contact> result = (List<Contact>) CollectionUtils.filter(
            contacts,
            'BirthDate',
            CollectionUtils.FilterOperator.GREATER_THAN,
            filterDate
        );
        System.assertEquals(5, result.size());
        for (Contact c : result) {
            System.assertEquals(true, c.BirthDate > filterDate);
        }
    }

    // PUBLIC API TESTS

    @IsTest
    static void groupBy_should_group_sobjects_by_field() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test2'),
            new Contact(LastName = 'Test3'),
            new Contact(LastName = null),
            new Contact()
        };

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'LastName'
        );

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);

        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        List<Contact> testContacts = result.get('Test');
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.LastName);
        }
        // 1 for Test2
        System.assertEquals(1, result.get('Test2').size());
        // 1 for Test3
        System.assertEquals(1, result.get('Test3').size());
        // 2 for null
        System.assertEquals(2, result.get(null).size());

        // assert keys (note: cannot convert Set<Object> to Set<String>)
        Set<Object> keys = result.keySet();
        System.assertEquals(4, keys.size());
        System.assertEquals(true, keys.contains('Test'));
        System.assertEquals(true, keys.contains('Test2'));
        System.assertEquals(true, keys.contains('Test3'));
        System.assertEquals(true, keys.contains(null));
    }

    @IsTest
    static void groupBy_should_group_queried_sobjects_by_field() {
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Test', FirstName = 'Test'),
            new Contact(LastName = 'Test', FirstName = 'Test'),
            new Contact(LastName = 'Test', FirstName = 'Test2'),
            new Contact(LastName = 'Test', FirstName = 'Test3'),
            new Contact(LastName = 'Test', FirstName = null),
            new Contact(LastName = 'Test')
        };
        insert contacts;
        contacts = [SELECT FirstName FROM Contact];

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'FirstName'
        );

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);

        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        List<Contact> testContacts = result.get('Test');
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.FirstName);
        }
        // 1 for Test2
        System.assertEquals(1, result.get('Test2').size());
        // 1 for Test3
        System.assertEquals(1, result.get('Test3').size());
        // 2 for null
        System.assertEquals(2, result.get(null).size());

        // assert keys (note: cannot convert Set<Object> to Set<String>)
        Set<Object> keys = result.keySet();
        System.assertEquals(4, keys.size());
        System.assertEquals(true, keys.contains('Test'));
        System.assertEquals(true, keys.contains('Test2'));
        System.assertEquals(true, keys.contains('Test3'));
        System.assertEquals(true, keys.contains(null));
    }

    @IsTest
    static void groupBy_should_group_sobjects_by_sobject_field() {
        // given
        Id testAccountId = IdUtils.newId(Account.SObjectType);
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = '0', Account = new Account(Id = testAccountId)),
            new Contact(LastName = '1', Account = new Account(Id = testAccountId)),
            new Contact(LastName = '2', Account = new Account(Id = testAccountId, Name = 'Test2')),
            new Contact(LastName = '3', Account = new Account(Name = 'Test2')),
            new Contact(LastName = '4', Account = new Account(Name = 'Test3')),
            new Contact(LastName = '5', Account = new Account()),
            new Contact(LastName = '6'),
            new Contact()
        };

        // test sobject equality
        System.assertEquals(contacts[0].Account, contacts[1].Account); // same id
        System.assertNotEquals(contacts[0].Account, contacts[2].Account); // same id but different names
        System.assertNotEquals(contacts[2].Account, contacts[3].Account); // same name but different ids
        System.assertNotEquals(contacts[5].Account, contacts[6].Account); // new account != null
        System.assertEquals(contacts[6].Account, contacts[7].Account); // both null

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'Account',
            true
        );

        // then - 6 grouped entries
        System.assertEquals(6, result.size(), result);

        // 2 for testAccountId
        List<Contact> values = result.get(new Account(Id = testAccountId));
        System.assertEquals(2, values.size(), values);
        // 1 for Test2
        values = result.get(new Account(Name = 'Test2'));
        System.assertEquals(1, values.size(), values);
        // 1 for Test2 with Id
        values = result.get(new Account(Id = testAccountId, Name = 'Test2'));
        System.assertEquals(1, values.size(), values);
        // 1 for Test3
        values = result.get(new Account(Name = 'Test3'));
        System.assertEquals(1, values.size(), values);
        // 1 for empty account
        values = result.get(new Account());
        System.assertEquals(1, values.size(), values);
        // 2 for null
        values = result.get(null);
        System.assertEquals(2, values.size(), values);
    }

    @IsTest
    static void groupBy_should_group_queried_sobjects_by_sobject_field() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test0'),
            new Account(Name = 'Test0'),
            new Account(Name = 'Test1'),
            new Account(Name = 'Test2')
        };
        insert accounts;
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = '0', AccountId = accounts[0].Id),
            new Contact(LastName = '1', AccountId = accounts[0].Id),
            new Contact(LastName = '2', AccountId = accounts[1].Id),
            new Contact(LastName = '3', AccountId = accounts[2].Id),
            new Contact(LastName = '4', AccountId = accounts[3].Id),
            new Contact(LastName = '5', AccountId = null),
            new Contact(LastName = '6')
        };
        insert contacts;
        contacts = [SELECT Account.Name FROM Contact];

        // test sobject equality
        System.assertEquals(contacts[0].Account, contacts[1].Account); // same account
        System.assertNotEquals(contacts[1].Account, contacts[2].Account); // different accounts with same name
        System.assertNotEquals(contacts[2].Account, contacts[3].Account); // different accounts with different name
        System.assertEquals(contacts[5].Account, contacts[6].Account); // both null

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'Account',
            true
        );

        // then - 5 grouped entries
        System.assertEquals(5, result.size(), result);

        // 2 for Test0
        List<Contact> values = result.get(contacts[0].Account);
        System.assertEquals(2, values.size(), values);
        // 1 for the other account named Test0
        values = result.get(contacts[2].Account);
        System.assertEquals(1, values.size(), values);
        // 1 for Test1
        values = result.get(contacts[3].Account);
        System.assertEquals(1, values.size(), values);
        // 1 for Test2
        values = result.get(contacts[4].Account);
        System.assertEquals(1, values.size(), values);
        // 2 for null
        values = result.get(null);
        System.assertEquals(2, values.size(), values);
    }

    @IsTest
    static void groupBy_should_group_sobjects_by_parent_field() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test2')),
            new Contact(Account = new Account(Name = 'Test3')),
            new Contact(Account = new Account(Name = null)),
            new Contact(Account = new Account()),
            new Contact()
        };

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'Account.Name'
        );

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);
        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        List<Contact> testContacts = result.get('Test');
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.Account.Name);
        }
        // 1 for Test2
        System.assertEquals(1, result.get('Test2').size());
        // 1 for Test3
        System.assertEquals(1, result.get('Test3').size());
        // 3 for null
        System.assertEquals(3, result.get(null).size());

        // assert keys (note: cannot convert Set<Object> to Set<String>)
        Set<Object> keys = result.keySet();
        System.assertEquals(4, keys.size());
        System.assertEquals(true, keys.contains('Test'));
        System.assertEquals(true, keys.contains('Test2'));
        System.assertEquals(true, keys.contains('Test3'));
        System.assertEquals(true, keys.contains(null));
    }

    @IsTest
    static void groupBy_should_group_queried_sobjects_by_parent_field() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test0'),
            new Account(Name = 'Test1'),
            new Account(Name = 'Test2')
        };
        insert accounts;
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Test', AccountId = accounts[0].Id),
            new Contact(LastName = 'Test', AccountId = accounts[0].Id),
            new Contact(LastName = 'Test', AccountId = accounts[1].Id),
            new Contact(LastName = 'Test', AccountId = accounts[2].Id),
            new Contact(LastName = 'Test', AccountId = null),
            new Contact(LastName = 'Test')
        };
        insert contacts;
        contacts = [SELECT Account.Name FROM Contact];

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'Account.Name'
        );

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);
        // 2 for Test0
        System.assertEquals(2, result.get('Test0').size());
        List<Contact> testContacts = result.get('Test0');
        for (Contact c : testContacts) {
            System.assertEquals('Test0', c.Account.Name);
        }
        // 1 for Test1
        System.assertEquals(1, result.get('Test1').size());
        // 1 for Test2
        System.assertEquals(1, result.get('Test2').size());
        // 2 for null
        System.assertEquals(2, result.get(null).size());
    }

    @IsTest
    static void groupBy_should_group_sobjects_by_grandparent_field() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(Account = new Account(Parent = new Account(Name = 'Test'))),
            new Contact(Account = new Account(Parent = new Account(Name = 'Test'))),
            new Contact(Account = new Account(Parent = new Account(Name = 'Test2'))),
            new Contact(Account = new Account(Parent = new Account(Name = 'Test3'))),
            new Contact(Account = new Account(Parent = new Account(Name = null))),
            new Contact(Account = new Account(Parent = new Account())),
            new Contact(Account = new Account()),
            new Contact()
        };

        // when
        Map<Object, List<Contact>> result = (Map<Object, List<Contact>>) CollectionUtils.groupBy(
            contacts,
            'Account.Parent.Name'
        );

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);
        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        List<Contact> testContacts = result.get('Test');
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.Account.Parent.Name);
        }
        // 1 for Test2
        System.assertEquals(1, result.get('Test2').size());
        // 1 for Test3
        System.assertEquals(1, result.get('Test3').size());
        // 4 for null
        System.assertEquals(4, result.get(null).size());

        // assert keys (note: cannot convert Set<Object> to Set<String>)
        Set<Object> keys = result.keySet();
        System.assertEquals(4, keys.size());
        System.assertEquals(true, keys.contains('Test'));
        System.assertEquals(true, keys.contains('Test2'));
        System.assertEquals(true, keys.contains('Test3'));
        System.assertEquals(true, keys.contains(null));
    }

    @IsTest
    static void filter_should_filter_sobjects_by_string_field() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = '0', LastName = 'Test'),
            new Contact(FirstName = '1', LastName = 'Test'),
            new Contact(FirstName = '2', LastName = 'Test2'),
            new Contact(FirstName = '3', LastName = 'Test3')
        };

        // when
        List<Contact> result = (List<Contact>) CollectionUtils.filter(
            contacts,
            'LastName',
            CollectionUtils.FilterOperator.EQUALS,
            'Test'
        );

        // then
        System.assertEquals(2, result.size());
        for (Contact c : result) {
            System.assertEquals('Test', c.LastName);
        }
    }

    @IsTest
    static void filter_should_filter_sobjects_by_sobject_field() {
        // given
        Account accountToFind = new Account(Id = IdUtils.id(1, Account.SObjectType));
        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'FindMe',
                Account = new Account(Id = IdUtils.id(1, Account.SObjectType))
            ),
            new Contact(
                FirstName = 'FindMeNot',
                Account = new Account(Id = IdUtils.id(0, Account.SObjectType))
            ),
            new Contact(
                FirstName = 'FindMeNot',
                Account = new Account(Id = IdUtils.id(1, Account.SObjectType), Name = 'Test')
            ),
            new Contact(FirstName = 'FindMeNot', Account = new Account()),
            new Contact(
                FirstName = 'FindMe',
                Account = new Account(Id = IdUtils.id(1, Account.SObjectType))
            )
        };

        // when
        List<Contact> result = (List<Contact>) CollectionUtils.filter(
            contacts,
            'Account',
            CollectionUtils.FilterOperator.EQUALS,
            accountToFind,
            true
        );

        // then
        System.assertEquals(2, result.size());
        for (Contact c : result) {
            System.assertEquals('FindMe', c.FirstName);
            System.assertEquals(accountToFind, c.Account);
        }
    }

    @IsTest
    static void filter_should_filter_integers() {
        // given
        List<Integer> ints = new List<Integer>{ 1, 2, 3, 4, 5 };

        // when
        List<Integer> result = (List<Integer>) CollectionUtils.filter(
            ints,
            CollectionUtils.FilterOperator.GREATER_THAN,
            3,
            new List<Integer>{}
        );

        // then
        System.assertEquals(2, result.size());
        System.assertEquals(new List<Integer>{ 4, 5 }, result);
    }

    @IsTest
    static void filter_should_convert_to_integer_list() {
        // given
        List<Integer> ints = new List<Integer>{ 1, 2, 3, 4, 5 };

        // when
        List<Integer> result = (List<Integer>) CollectionUtils.filter(
            ints,
            CollectionUtils.FilterOperator.GREATER_THAN,
            3
        );

        // then
        System.assertEquals(2, result.size());
        System.assertEquals(new List<Integer>{ 4, 5 }, result);
    }

    @IsTest
    static void pluck_should_pluck_values_from_sobjects() {
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = '0', LastName = 'Test'),
            new Contact(FirstName = '1', LastName = 'Test'),
            new Contact(FirstName = '2', LastName = 'Test2'),
            new Contact(FirstName = '3', LastName = 'Test3')
        };

        // when
        List<String> result = (List<String>) CollectionUtils.pluck(
            contacts,
            'FirstName',
            new List<String>{}
        );

        // then
        System.assertEquals(contacts.size(), result.size());
        System.assertEquals(new List<String>{ '0', '1', '2', '3' }, result);
        // order is preserved
        for (Integer idx = 0; idx < result.size(); idx++) {
            Contact c = contacts.get(idx);
            String resultStr = result.get(idx);
            System.assertEquals(c.FirstName, resultStr);
        }
    }

    @IsTest
    static void flatten_should_flatten_nested_lists() {
        List<Object> objList = new List<Object>{
            1,
            2,
            new List<Object>{ 3, 4, new List<Object>{ 5, 6 } },
            7,
            new List<Object>{ 8, 9 }
        };

        // when
        List<Integer> result = (List<Integer>) CollectionUtils.flatten(objList, new List<Integer>{});

        // then
        System.assertEquals(new List<Integer>{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, result);
    }

    @IsTest
    static void difference_should_fill_provided_list() {
        List<Integer> listA = new List<Integer>{ 1, 2, 3 };
        List<Integer> listB = new List<Integer>{ 3, 4, 5 };

        // when
        List<Integer> result = (List<Integer>) CollectionUtils.difference(
            listA,
            listB,
            new List<Integer>{}
        );

        // then
        System.assertEquals(new List<Integer>{ 1, 2 }, result);
    }

    @IsTest
    static void intersect_should_fill_provided_list() {
        List<Integer> listA = new List<Integer>{ 1, 2, 3 };
        List<Integer> listB = new List<Integer>{ 3, 4, 5 };

        // when
        List<Integer> result = (List<Integer>) CollectionUtils.intersect(listA, listB, new List<Integer>{});

        // then
        System.assertEquals(new List<Integer>{ 3 }, result);
    }

    @IsTest
    static void union_should_fill_provided_list() {
        List<Integer> listA = new List<Integer>{ 1, 2, 3 };
        List<Integer> listB = new List<Integer>{ 3, 4, 5 };

        // when
        List<Integer> result = (List<Integer>) CollectionUtils.union(listA, listB, new List<Integer>{});

        // then
        System.assertEquals(new List<Integer>{ 1, 2, 3, 4, 5 }, result);
    }

    @IsTest
    static void removeNulls_should_remove_null_entries_from_list() {
        List<Integer> objList = new List<Integer>{ null, 1, null, 2 };
        System.assertEquals(4, objList.size());

        List<Integer> result = (List<Integer>) CollectionUtils.removeNulls(objList, new List<Integer>{});
        System.assertEquals(2, result.size());
        for (Integer i : result) {
            System.assertNotEquals(null, i);
        }
        System.assertEquals(new List<Integer>{ 1, 2 }, result);
    }

    @IsTest
    static void removeNulls_should_filter_sobjects_where_field_is_null() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test2'),
            new Contact(LastName = 'Test3'),
            new Contact(LastName = null),
            new Contact()
        };

        // when
        List<Contact> result = (List<Contact>) CollectionUtils.removeNulls(contacts, 'LastName');

        // then
        System.assertEquals(4, result.size());
        for (Contact c : result) {
            System.assertNotEquals(null, c.LastName);
        }
    }

    @IsTest
    static void removeNulls_should_filter_sobjects_where_sobject_field_is_null() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test2')),
            new Contact(Account = new Account(Name = 'Test3')),
            new Contact(Account = new Account()),
            new Contact()
        };

        // when
        List<Contact> result = (List<Contact>) CollectionUtils.removeNulls(contacts, 'Account', true);

        // then
        System.assertEquals(5, result.size());
        for (Contact c : result) {
            System.assertNotEquals(null, c.Account);
        }
    }

    @IsTest
    static void removeNulls_should_filter_sobjects_where_grandparent_field_is_null() {
        // given
        List<Contact> contacts = new List<Contact>{
            new Contact(Account = new Account(Parent = new Account(Name = 'Test'))),
            new Contact(Account = new Account(Parent = new Account(Name = 'Test'))),
            new Contact(Account = new Account(Parent = new Account(Name = 'Test2'))),
            new Contact(Account = new Account(Parent = new Account(Name = 'Test3'))),
            new Contact(Account = new Account(Parent = new Account(Name = null))),
            new Contact(Account = new Account(Parent = new Account())),
            new Contact(Account = new Account()),
            new Contact()
        };

        // when
        List<Contact> result = (List<Contact>) CollectionUtils.removeNulls(contacts, 'Account.Parent.Name');

        // then
        System.assertEquals(4, result.size());
        for (Contact c : result) {
            System.assertNotEquals(null, c.Account.Parent.Name);
        }

        System.assertEquals(null, new Contact().get('LastName'));
        System.assertEquals(null, new Contact().getSObject('Account'));
    }

    @IsTest
    static void toSObjectList_should_convert_objects_to_sobjects() {
        List<Object> objList = new List<Object>{ new Account(), new Account(), null };

        // when
        List<Account> result = (List<Account>) CollectionUtils.toSObjectList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toStringList_should_convert_objects_to_Strings() {
        List<Object> objList = new List<Object>{ 'test', 'test2', null };

        // when
        List<String> result = CollectionUtils.toStringList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toIdList_should_convert_objects_to_Ids() {
        List<Object> objList = new List<Object>{
            IdUtils.newId(Account.SObjectType),
            IdUtils.newId(Account.SObjectType),
            null
        };

        // when
        List<Id> result = CollectionUtils.toIdList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toIntegerList_should_convert_objects_to_Integers() {
        List<Object> objList = new List<Object>{ 1.0, '2.0', 3, 4L, null };

        // when
        List<Integer> result = CollectionUtils.toIntegerList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toLongList_should_convert_objects_to_Longs() {
        List<Object> objList = new List<Object>{ 1.0, '2.0', 3, 4L, null };

        // when
        List<Long> result = CollectionUtils.toLongList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toDoubleList_should_convert_objects_to_Doubles() {
        List<Object> objList = new List<Object>{ 1.0, '2.0', 3, 4L, null };

        // when
        List<Double> result = CollectionUtils.toDoubleList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toDecimalList_should_convert_objects_to_Decimals() {
        List<Object> objList = new List<Object>{ 1.0, '2.0', 3, 4L, null };

        // when
        List<Decimal> result = CollectionUtils.toDecimalList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toBooleanList_should_convert_objects_to_Booleans() {
        List<Object> objList = new List<Object>{ true, 'false', null };

        // when
        List<Boolean> result = CollectionUtils.toBooleanList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toDateList_should_convert_objects_to_Dates() {
        List<Object> objList = new List<Object>{
            Date.newInstance(2017, 1, 2),
            Datetime.newInstanceGmt(2017, 1, 2),
            '2017-01-02',
            '2017-01-02T00:00:00.000Z',
            '2017-01-02 00:00:00.000Z',
            null
        };

        // when
        List<Date> result = CollectionUtils.toDateList(objList);

        // then
        System.assertEquals(6, result.size());
        for (Date test : result) {
            if (test != null) {
                System.assertEquals(Date.newInstance(2017, 1, 2), test);
            }
        }
    }

    @IsTest
    static void toDateTimeList_should_convert_objects_to_DateTimes() {
        List<Object> objList = new List<Object>{
            Date.newInstance(2017, 1, 2), // local timezone
            Datetime.newInstanceGmt(2017, 1, 2),
            // '2017-01-01',
            '2017-01-01 00:00:00.000Z',
            null
        };

        // when
        List<Datetime> result = CollectionUtils.toDateTimeList(objList);

        // then
        System.assertEquals(4, result.size());
    }

    @IsTest
    static void toTimeList_should_convert_objects_to_Times() {
        List<Object> objList = new List<Object>{ Time.newInstance(0, 0, 0, 0), null };

        // when
        List<Time> result = CollectionUtils.toTimeList(objList);

        // then
        System.assertEquals(2, result.size());
    }

    @IsTest
    static void toBlobList_should_convert_objects_to_Blobs() {
        List<Object> objList = new List<Object>{ Blob.valueOf('test'), 'test', null };

        // when
        List<Blob> result = CollectionUtils.toBlobList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    // UNIT TESTS

    @IsTest
    static void getType_should_evaluate_types_dynamically() {
        System.assertEquals('', CollectionUtils.getType(null));
        System.assertEquals('SObject', CollectionUtils.getType(new Account()));
        System.assertEquals('Boolean', CollectionUtils.getType(true));
        System.assertEquals('Id', CollectionUtils.getType(IdUtils.newId(Account.SObjectType)));
        System.assertEquals('String', CollectionUtils.getType('test'));
        System.assertEquals('Blob', CollectionUtils.getType(Blob.valueOf('test')));
        System.assertEquals('Date', CollectionUtils.getType(Date.today()));
        System.assertEquals('Datetime', CollectionUtils.getType(DateTime.now()));
        System.assertEquals('Time', CollectionUtils.getType(Time.newInstance(0, 0, 0, 0)));
        System.assertEquals('Integer', CollectionUtils.getType(1));
        System.assertEquals('Long', CollectionUtils.getType(1L));
        System.assertEquals('Decimal', CollectionUtils.getType(1.0));
        // System.assertEquals('Double', CollectionUtils.getType(Double.valueOf(1)));
        System.assertEquals('List', CollectionUtils.getType(new List<Integer>{}));
        System.assertEquals('List', CollectionUtils.getType(new List<Account>{}));
        System.assertEquals('Object', CollectionUtils.getType(new Set<String>()));
        System.assertEquals('Object', CollectionUtils.getType(new Set<Account>()));
        System.assertEquals('Object', CollectionUtils.getType(new Map<String, String>()));
        System.assertEquals('Object', CollectionUtils.getType(new Map<String, Account>()));
        System.assertEquals('Object', CollectionUtils.getType(new Map<Account, Account>()));
    }

    @IsTest
    static void getValueFromSObject_should_get_field_value() {
        // given
        Contact c = new Contact(
            LastName = 'Test',
            Account = new Account(Name = 'AcctName', Parent = new Account(Name = 'ParentAcctName'))
        );

        System.assertEquals('Test', CollectionUtils.getValueFromSObject(c, 'LastName'));
        System.assertEquals('AcctName', CollectionUtils.getValueFromSObject(c, 'Account.Name'));
        System.assertEquals(
            'ParentAcctName',
            CollectionUtils.getValueFromSObject(c, 'Account.Parent.Name')
        );
        System.assertEquals(
            null,
            CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent.Name')
        );
        System.assertEquals(
            null,
            CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent.Parent.Name')
        );
    }

    @IsTest
    static void getValueFromSObject_should_get_sobject_value() {
        // given
        Contact c = new Contact(
            LastName = 'Test',
            Account = new Account(Name = 'AcctName', Parent = new Account(Name = 'ParentAcctName'))
        );

        System.assertEquals(c.Account, CollectionUtils.getValueFromSObject(c, 'Account', true));
        System.assertEquals(
            c.Account.Parent,
            CollectionUtils.getValueFromSObject(c, 'Account.Parent', true)
        );
        System.assertEquals(
            null,
            CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent', true)
        );
        System.assertEquals(
            null,
            CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent.Parent', true)
        );
    }

    @IsTest
    static void evalOperator_should_eval_SObjects() {
        Account one = new Account(Name = '1');
        Account zero = new Account(Name = '0');

        // equals
        assertEvalOperatorEquals(one, zero);

        // not equals
        assertEvalOperatorNotEquals(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Strings() {
        assertAllEvalOperators('1', '0');
        assertAllEvalOperators('0', '');
    }

    @IsTest
    static void evalOperator_should_eval_Ids() {
        Id one = IdUtils.id(1, Account.SObjectType);
        Id zero = IdUtils.id(0, Account.SObjectType);
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Integers() {
        Integer one = 1;
        Integer zero = 0;
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Longs() {
        Long one = 1;
        Long zero = 0;
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Doubles() {
        Double one = 1;
        Double zero = 0;
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Decimals() {
        Decimal one = 1;
        Decimal zero = 0;
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Dates() {
        Date one = Date.newInstance(0, 0, 1);
        Date zero = Date.newInstance(0, 0, 0);
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_DateTimes() {
        DateTime one = DateTime.newInstance(0, 0, 1);
        DateTime zero = DateTime.newInstance(0, 0, 0);
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Times() {
        Time one = Time.newInstance(0, 0, 0, 1);
        Time zero = Time.newInstance(0, 0, 0, 0);
        assertAllEvalOperators(one, zero);
    }

    @IsTest
    static void evalOperator_should_eval_Comparables() {
        TestComparable one = new TestComparable(1);
        TestComparable zero = new TestComparable(0);
        assertAllEvalOperators(one, zero);
    }

    private static void assertAllEvalOperators(Object one, Object zero) {
        // equals
        assertEvalOperatorEquals(one, zero);

        // not equals
        assertEvalOperatorNotEquals(one, zero);

        assertEvalOperatorComparables(one, zero);
    }

    private static void assertEvalOperatorEquals(Object one, Object zero) {
        CollectionUtils.FilterOperator operator = CollectionUtils.FilterOperator.EQUALS;
        assertSupportsOperator(operator, one, zero);

        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, null));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, null));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, null));
    }

    private static void assertEvalOperatorNotEquals(Object one, Object zero) {
        CollectionUtils.FilterOperator operator = CollectionUtils.FilterOperator.NOT_EQUALS;
        assertSupportsOperator(operator, one, zero);

        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, null));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, null));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, null));
    }

    private static void assertEvalOperatorComparables(Object one, Object zero) {
        // greater than
        CollectionUtils.FilterOperator operator = CollectionUtils.FilterOperator.GREATER_THAN;
        assertSupportsOperator(operator, one, zero);
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, null));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, null));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, null));

        // less than
        operator = CollectionUtils.FilterOperator.LESS_THAN;
        assertSupportsOperator(operator, one, zero);
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, null));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, null));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, null));

        // greater than or equals
        operator = CollectionUtils.FilterOperator.GREATER_THAN_OR_EQUALS;
        assertSupportsOperator(operator, one, zero);
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, one));
        System.assertEquals(false, CollectionUtils.evalOperator(null, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, null));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, null));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, null));

        // less than or equals
        operator = CollectionUtils.FilterOperator.LESS_THAN_OR_EQUALS;
        assertSupportsOperator(operator, one, zero);
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, zero));
        System.assertEquals(true, CollectionUtils.evalOperator(zero, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(one, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, one));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, zero));
        System.assertEquals(false, CollectionUtils.evalOperator(one, operator, null));
        System.assertEquals(false, CollectionUtils.evalOperator(zero, operator, null));
        System.assertEquals(true, CollectionUtils.evalOperator(null, operator, null));
    }

    private static void assertSupportsOperator(
        CollectionUtils.FilterOperator operator,
        Object one,
        Object zero
    ) {
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, one, zero));
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, one, null));
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, null, zero));
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, null, null));
    }

    @IsTest
    static void convertObjectList_should_detect_and_convert_objects_into_concrete_list() {
        // type detection - type detected by first non-null item in list

        // integer
        List<Object> objList = new List<Object>{ null, 1, 1L, 1.0 };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Integer>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Long>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Decimal>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Double>);

        // long
        objList = new List<Object>{ null, 1L, 1, 1.0 };
        System.assertEquals(false, CollectionUtils.convertObjectList(objList) instanceof List<Integer>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Long>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Decimal>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Double>);

        // decimal / double
        objList = new List<Object>{ null, 1.0, 1, 1L };
        System.assertEquals(false, CollectionUtils.convertObjectList(objList) instanceof List<Integer>);
        System.assertEquals(false, CollectionUtils.convertObjectList(objList) instanceof List<Long>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Decimal>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Double>);

        // String
        objList = new List<Object>{ null, 'test' };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<String>);

        // Id
        objList = new List<Object>{ null, IdUtils.newId(Account.SObjectType) };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Id>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<String>);

        // Boolean
        objList = new List<Object>{ null, true, false };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Boolean>);

        // Blob
        objList = new List<Object>{ null, Blob.valueOf('test') };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Blob>);

        // Date
        objList = new List<Object>{ null, Date.today(), DateTime.now() };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Date>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Datetime>);

        // DateTime
        objList = new List<Object>{ null, DateTime.now(), Date.today() };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Datetime>);

        // Time
        objList = new List<Object>{ null, Time.newInstance(0, 0, 0, 0) };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Time>);

        // SObject
        objList = new List<Object>{ null, new Account() };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<SObject>);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof List<Account>);

        // unable to convert these types - assert list is same reference
        // null
        objList = new List<Object>{ null, null, null };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
        // list
        objList = new List<Object>{ null, new List<String>() };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
        // set
        objList = new List<Object>{ null, new Set<String>() };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
        // map
        objList = new List<Object>{ null, new Map<String, String>() };
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
    }

    class TestComparable implements Comparable {
        public Integer value { get; set; }

        public TestComparable(Integer value) {
            this.value = value;
        }

        public Integer compareTo(Object compareTo) {
            TestComparable compareToObj = (TestComparable) compareTo;
            if (this.value == compareToObj.value) {
                return 0;
            } else if (this.value > compareToObj.value) {
                return 1;
            }
            return -1;
        }
    }
}
