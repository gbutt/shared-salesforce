@IsTest
public class CollectionUtilsTest {
    // EXAMPLES

    @IsTest
    static void example_pluck_account_ids_for_query() {
        // build ten contacts
        Contact[] contacts = new Contact[10];
        for (Integer idx = 0; idx < contacts.size(); idx++) {
            contacts[idx] = new Contact(
                Id = IdUtils.id(idx, Contact.SObjectType)
                , FirstName = String.valueOf(idx)
                , LastName = 'Test'
                , AccountId = IdUtils.id(idx, Account.SObjectType)
            );
        }

        // pluck the Account Ids
        Id[] accountIds = (Id[])CollectionUtils.pluck(contacts, 'AccountId', new Id[] {});
        System.assertEquals(10, accountIds.size());
        Account[] accounts = [SELECT Id FROM Account WHERE Id IN :accountIds];
    }

    @IsTest
    static void example_split_contacts_by_lastname_version_1() {
        Contact[] contacts = new Contact[] {
            new Contact(FirstName = '0', LastName = 'Test', Email = 'test')
            , new Contact(FirstName = '1', LastName = 'Test', Email = 'test')
            , new Contact(FirstName = '2', LastName = 'Test2', Email = 'test')
            , new Contact(FirstName = '3', LastName = 'Test2', Email = 'test')
            , new Contact(FirstName = '4', LastName = 'Test3', Email = 'test')
        };

        // split all contacts with lastname = Test and lastname != Test
        // 1. group by LastName
        Map<Object, SObject[]> groupedByLastName = CollectionUtils.groupBy(contacts, 'LastName');
        // 2, get contacts with LastName = 'Test'
        Contact[] testContacts = (Contact[])groupedByLastName.get('Test');
        // 3. get all contacts not in the testContacts list
        Contact[] notTestContacts = (Contact[])CollectionUtils.difference(contacts, testContacts, new Contact[] {});

        // all contacts have LastName = Test
        System.assertEquals(2, testContacts.size());
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.LastName);
        }
        // all contacts have LastName != Test
        System.assertEquals(contacts.size() - testContacts.size(), notTestContacts.size(), notTestContacts);
        for (Contact c : notTestContacts) {
            System.assertNotEquals('Test', c.LastName);
        }
    }

    @IsTest
    static void example_split_contacts_by_lastname_version_2() {
        Contact[] contacts = new Contact[] {
            new Contact(FirstName = '0', LastName = 'Test', Email = 'test')
            , new Contact(FirstName = '1', LastName = 'Test', Email = 'test')
            , new Contact(FirstName = '2', LastName = 'Test2', Email = 'test')
            , new Contact(FirstName = '3', LastName = 'Test2', Email = 'test')
            , new Contact(FirstName = '4', LastName = 'Test3', Email = 'test')
        };

        // another way to split all contacts with lastname = Test and lastname != Test
        // 1. group by LastName
        Map<Object, SObject[]> groupedByLastName = CollectionUtils.groupBy(contacts, 'LastName');
        // 2. remove 'Test' entry from the map
        Contact[] testContacts = (Contact[])groupedByLastName.remove('Test');
        // 3. flatten the remaining values into a list
        Contact[] notTestContacts = (Contact[])CollectionUtils.flatten(groupedByLastName.values(), new Contact[] {});

        // all contacts have LastName = Test
        System.assertEquals(2, testContacts.size());
        for (Contact c : testContacts) {
            System.assertEquals('Test', c.LastName);
        }

        // all contacts have LastName != Test
        System.assertEquals(contacts.size() - testContacts.size(), notTestContacts.size(), notTestContacts);
        for (Contact c : notTestContacts) {
            System.assertNotEquals('Test', c.LastName);
        }
    }

    @IsTest
    static void example_filter_contacts_by_date() {
        // 10 contacts with birthdays between jan 1 and jan 10
        Contact[] contacts = new Contact[10];
        for (Integer idx = 0; idx < contacts.size(); idx++) {
            contacts[idx] = new Contact(
                Id = IdUtils.id(idx, Contact.SObjectType)
                , BirthDate = Date.newInstance(2000, 1, idx + 1)
            );
        }

        Date filterDate = Date.newInstance(2000, 1, 5);
        Contact[] result = (Contact[])CollectionUtils.filter(contacts, 'BirthDate', CollectionUtils.FilterOperator.GREATER_THAN, filterDate);
        System.assertEquals(5, result.size());
        for (Contact c : result) {
            System.assertEquals(true, c.BirthDate > filterDate);
        }
    }

    // PUBLIC API TESTS

    @IsTest
    static void groupBy_should_group_sobjects_by_field() {
        // given
        Contact[] contacts = new Contact[] {
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test2'),
            new Contact(LastName = 'Test3'),
            new Contact(LastName = null),
            new Contact()
        };

        // when
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'LastName');

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);

        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        Contact[] testContacts = result.get('Test');
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
        Contact[] contacts = new Contact[] {
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
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'FirstName');

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);

        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        Contact[] testContacts = result.get('Test');
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
        Contact[] contacts = new Contact[] {
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
        System.assertEquals(contacts[0].Account, contacts[1].Account);  // same id
        System.assertNotEquals(contacts[0].Account, contacts[2].Account);  // same id but different names
        System.assertNotEquals(contacts[2].Account, contacts[3].Account);  // same name but different ids
        System.assertNotEquals(contacts[5].Account, contacts[6].Account);  // new account != null
        System.assertEquals(contacts[6].Account, contacts[7].Account);  // both null

        // when
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'Account', true);

        // then - 6 grouped entries
        System.assertEquals(6, result.size(), result);

        // 2 for testAccountId
        Contact[] values = result.get(new Account(Id = testAccountId));
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
        Account[] accounts = new Account[] {
            new Account(Name = 'Test0')
            , new Account(Name = 'Test0')
            , new Account(Name = 'Test1')
            , new Account(Name = 'Test2')
        };
        insert accounts;
        Contact[] contacts = new Contact[] {
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
        System.assertEquals(contacts[0].Account, contacts[1].Account);  // same account
        System.assertNotEquals(contacts[1].Account, contacts[2].Account);  // different accounts with same name
        System.assertNotEquals(contacts[2].Account, contacts[3].Account);  // different accounts with different name
        System.assertEquals(contacts[5].Account, contacts[6].Account);  // both null

        // when
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'Account', true);

        // then - 5 grouped entries
        System.assertEquals(5, result.size(), result);

        // 2 for Test0
        Contact[] values = result.get(contacts[0].Account);
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
        Contact[] contacts = new Contact[] {
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test2')),
            new Contact(Account = new Account(Name = 'Test3')),
            new Contact(Account = new Account(Name = null)),
            new Contact(Account = new Account()),
            new Contact()
        };

        // when
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'Account.Name');

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);
        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        Contact[] testContacts = result.get('Test');
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
        Account[] accounts = new Account[] {
            new Account(Name = 'Test0')
            , new Account(Name = 'Test1')
            , new Account(Name = 'Test2')
        };
        insert accounts;
        Contact[] contacts = new Contact[] {
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
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'Account.Name');

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);
        // 2 for Test0
        System.assertEquals(2, result.get('Test0').size());
        Contact[] testContacts = result.get('Test0');
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
        Contact[] contacts = new Contact[] {
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
        Map<Object, Contact[]> result = (Map<Object, Contact[]>)CollectionUtils.groupBy(contacts, 'Account.Parent.Name');

        // then - 4 grouped entries
        System.assertEquals(4, result.size(), result);
        // 2 for Test
        System.assertEquals(2, result.get('Test').size());
        Contact[] testContacts = result.get('Test');
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
        Contact[] contacts = new Contact[] {
            new Contact(FirstName = '0', LastName = 'Test'),
            new Contact(FirstName = '1', LastName = 'Test'),
            new Contact(FirstName = '2', LastName = 'Test2'),
            new Contact(FirstName = '3', LastName = 'Test3')
        };

        // when
        Contact[] result = (Contact[])CollectionUtils.filter(contacts, 'LastName', CollectionUtils.FilterOperator.EQUALS, 'Test');

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
        Contact[] contacts = new Contact[] {
            new Contact(FirstName = 'FindMe', Account = new Account(Id = IdUtils.id(1, Account.SObjectType)))
            , new Contact(FirstName = 'FindMeNot', Account = new Account(Id = IdUtils.id(0, Account.SObjectType)))
            , new Contact(FirstName = 'FindMeNot', Account = new Account(Id = IdUtils.id(1, Account.SObjectType), Name = 'Test'))
            , new Contact(FirstName = 'FindMeNot', Account = new Account())
            , new Contact(FirstName = 'FindMe', Account = new Account(Id = IdUtils.id(1, Account.SObjectType)))
        };

        // when
        Contact[] result = (Contact[])CollectionUtils.filter(contacts, 'Account', CollectionUtils.FilterOperator.EQUALS, accountToFind, true);

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
        Integer[] ints = new Integer[] {1, 2, 3, 4, 5};

        // when
        Integer[] result = (Integer[])CollectionUtils.filter(ints, CollectionUtils.FilterOperator.GREATER_THAN, 3, new Integer[] {});

        // then
        System.assertEquals(2, result.size());
        System.assertEquals(new Integer[] {4, 5}, result);
    }

    @IsTest
    static void filter_should_convert_to_integer_list() {
        // given
        Integer[] ints = new Integer[] {1, 2, 3, 4, 5};

        // when
        Integer[] result = (Integer[])CollectionUtils.filter(ints, CollectionUtils.FilterOperator.GREATER_THAN, 3);

        // then
        System.assertEquals(2, result.size());
        System.assertEquals(new Integer[] {4, 5}, result);
    }

    @IsTest
    static void pluck_should_pluck_values_from_sobjects() {
        Contact[] contacts = new Contact[] {
            new Contact(FirstName = '0', LastName = 'Test')
            , new Contact(FirstName = '1', LastName = 'Test')
            , new Contact(FirstName = '2', LastName = 'Test2')
            , new Contact(FirstName = '3', LastName = 'Test3')
        };

        // when
        String[] result = (String[])CollectionUtils.pluck(contacts, 'FirstName', new String[] {});

        // then
        System.assertEquals(contacts.size(), result.size());
        System.assertEquals(new String[] {'0', '1', '2', '3'}, result);
        // order is preserved
        for (Integer idx = 0; idx < result.size(); idx++) {
            Contact c = contacts.get(idx);
            String resultStr = result.get(idx);
            System.assertEquals(c.FirstName, resultStr);
        }
    }

    @IsTest
    static void flatten_should_flatten_nested_lists() {
        Object[] objList = new Object[] {
            1, 2
            , new Object[] {
                3, 4
                , new Object[] {5, 6}
            }
            , 7
            , new Object[] {
                8, 9
            }
        };

        // when
        Integer[] result = (Integer[])CollectionUtils.flatten(objList, new Integer[] {});

        // then
        System.assertEquals(new Integer[] {1, 2, 3, 4, 5, 6, 7, 8, 9}, result);
    }

    @IsTest
    static void difference_should_fill_provided_list() {
        Integer[] listA = new Integer[] {1, 2, 3};
        Integer[] listB = new Integer[] {3, 4, 5};

        // when
        Integer[] result = (Integer[])CollectionUtils.difference(listA, listB, new Integer[] {});

        // then
        System.assertEquals(new Integer[] {1, 2}, result);
    }

    @IsTest
    static void intersect_should_fill_provided_list() {
        Integer[] listA = new Integer[] {1, 2, 3};
        Integer[] listB = new Integer[] {3, 4, 5};

        // when
        Integer[] result = (Integer[])CollectionUtils.intersect(listA, listB, new Integer[] {});

        // then
        System.assertEquals(new Integer[] {3}, result);
    }

    @IsTest
    static void union_should_fill_provided_list() {
        Integer[] listA = new Integer[] {1, 2, 3};
        Integer[] listB = new Integer[] {3, 4, 5};

        // when
        Integer[] result = (Integer[])CollectionUtils.union(listA, listB, new Integer[] {});

        // then
        System.assertEquals(new Integer[] {1, 2, 3, 4, 5}, result);
    }

    @IsTest
    static void removeNulls_should_remove_null_entries_from_list() {
        Integer[] objList = new Integer[] {
            null
            , 1
            , null
            , 2
        };
        System.assertEquals(4, objList.size());

        Integer[] result = (Integer[])CollectionUtils.removeNulls(objList, new Integer[] {});
        System.assertEquals(2, result.size());
        for (Integer i : result) {
            System.assertNotEquals(null, i);
        }
        System.assertEquals(new Integer[] {1, 2}, result);
    }

    @IsTest
    static void removeNulls_should_filter_sobjects_where_field_is_null() {
        // given
        Contact[] contacts = new Contact[] {
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test'),
            new Contact(LastName = 'Test2'),
            new Contact(LastName = 'Test3'),
            new Contact(LastName = null),
            new Contact()
        };

        // when
        Contact[] result = (Contact[])CollectionUtils.removeNulls(contacts, 'LastName');

        // then
        System.assertEquals(4, result.size());
        for (Contact c : result) {
            System.assertNotEquals(null, c.LastName);
        }
    }

    @IsTest
    static void removeNulls_should_filter_sobjects_where_sobject_field_is_null() {
        // given
        Contact[] contacts = new Contact[] {
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test')),
            new Contact(Account = new Account(Name = 'Test2')),
            new Contact(Account = new Account(Name = 'Test3')),
            new Contact(Account = new Account()),
            new Contact()
        };

        // when
        Contact[] result = (Contact[])CollectionUtils.removeNulls(contacts, 'Account', true);

        // then
        System.assertEquals(5, result.size());
        for (Contact c : result) {
            System.assertNotEquals(null, c.Account);
        }
    }

    @IsTest
    static void removeNulls_should_filter_sobjects_where_grandparent_field_is_null() {
        // given
        Contact[] contacts = new Contact[] {
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
        Contact[] result = (Contact[])CollectionUtils.removeNulls(contacts, 'Account.Parent.Name');

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
        Object[] objList = new Object[] {
            new Account(),
            new Account(),
            null
        };

        // when
        Account[] result = (Account[])CollectionUtils.toSObjectList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toStringList_should_convert_objects_to_Strings() {
        Object[] objList = new Object[] {
            'test',
            'test2',
            null
        };

        // when
        String[] result = CollectionUtils.toStringList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toIdList_should_convert_objects_to_Ids() {
        Object[] objList = new Object[] {
            IdUtils.newId(Account.SObjectType),
            IdUtils.newId(Account.SObjectType),
            null
        };

        // when
        Id[] result = CollectionUtils.toIdList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toIntegerList_should_convert_objects_to_Integers() {
        Object[] objList = new Object[] {
            1.0,
            '2.0',
            3,
            4l,
            null
        };

        // when
        Integer[] result = CollectionUtils.toIntegerList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toLongList_should_convert_objects_to_Longs() {
        Object[] objList = new Object[] {
            1.0,
            '2.0',
            3,
            4l,
            null
        };

        // when
        Long[] result = CollectionUtils.toLongList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toDoubleList_should_convert_objects_to_Doubles() {
        Object[] objList = new Object[] {
            1.0,
            '2.0',
            3,
            4l,
            null
        };

        // when
        Double[] result = CollectionUtils.toDoubleList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toDecimalList_should_convert_objects_to_Decimals() {
        Object[] objList = new Object[] {
            1.0,
            '2.0',
            3,
            4l,
            null
        };

        // when
        Decimal[] result = CollectionUtils.toDecimalList(objList);

        // then
        System.assertEquals(5, result.size());
    }

    @IsTest
    static void toBooleanList_should_convert_objects_to_Booleans() {
        Object[] objList = new Object[] {
            true,
            'false',
            null
        };

        // when
        Boolean[] result = CollectionUtils.toBooleanList(objList);

        // then
        System.assertEquals(3, result.size());
    }

    @IsTest
    static void toDateList_should_convert_objects_to_Dates() {
        Object[] objList = new Object[] {
            Date.newInstance(2017, 1, 2),
            Datetime.newInstanceGmt(2017, 1, 2),
            '2017-01-02',
            '2017-01-02T00:00:00.000Z',
            '2017-01-02 00:00:00.000Z',
            null
        };

        // when
        Date[] result = CollectionUtils.toDateList(objList);

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
        Object[] objList = new Object[] {
            Date.newInstance(2017, 1, 2),  // local timezone
            Datetime.newInstanceGmt(2017, 1, 2),
            // '2017-01-01',
            '2017-01-01 00:00:00.000Z',
            null
        };

        // when
        DateTime[] result = CollectionUtils.toDateTimeList(objList);

        // then
        System.assertEquals(4, result.size());
    }

    @IsTest
    static void toTimeList_should_convert_objects_to_Times() {
        Object[] objList = new Object[] {
            Time.newInstance(0, 0, 0, 0),
            null
        };

        // when
        Time[] result = CollectionUtils.toTimeList(objList);

        // then
        System.assertEquals(2, result.size());
    }

    @IsTest
    static void toBlobList_should_convert_objects_to_Blobs() {
        Object[] objList = new Object[] {
            Blob.valueOf('test')
            , 'test'
            , null
        };

        // when
        Blob[] result = CollectionUtils.toBlobList(objList);

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
        System.assertEquals('Long', CollectionUtils.getType(1l));
        System.assertEquals('Decimal', CollectionUtils.getType(1.0));
        // System.assertEquals('Double', CollectionUtils.getType(Double.valueOf(1)));
        System.assertEquals('List', CollectionUtils.getType(new Integer[] {}));
        System.assertEquals('List', CollectionUtils.getType(new Account[] {}));
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
            LastName = 'Test'
            , Account = new Account(
                Name = 'AcctName'
                , Parent = new Account(
                    Name = 'ParentAcctName'
                )
            )
        );

        System.assertEquals('Test', CollectionUtils.getValueFromSObject(c, 'LastName'));
        System.assertEquals('AcctName', CollectionUtils.getValueFromSObject(c, 'Account.Name'));
        System.assertEquals('ParentAcctName', CollectionUtils.getValueFromSObject(c, 'Account.Parent.Name'));
        System.assertEquals(null, CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent.Name'));
        System.assertEquals(null, CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent.Parent.Name'));
    }

    @IsTest
    static void getValueFromSObject_should_get_sobject_value() {
        // given
        Contact c = new Contact(
            LastName = 'Test'
            , Account = new Account(
                Name = 'AcctName'
                , Parent = new Account(
                    Name = 'ParentAcctName'
                )
            )
        );

        System.assertEquals(c.Account, CollectionUtils.getValueFromSObject(c, 'Account', true));
        System.assertEquals(c.Account.Parent, CollectionUtils.getValueFromSObject(c, 'Account.Parent', true));
        System.assertEquals(null, CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent', true));
        System.assertEquals(null, CollectionUtils.getValueFromSObject(c, 'Account.Parent.Parent.Parent', true));
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

    private static void assertSupportsOperator(CollectionUtils.FilterOperator operator, Object one, Object zero) {
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, one, zero));
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, one, null));
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, null, zero));
        System.assertEquals(true, CollectionUtils.supportsOperator(operator, null, null));
    }

    @IsTest
    static void convertObjectList_should_detect_and_convert_objects_into_concrete_list() {
        // type detection - type detected by first non-null item in list

        // integer
        Object[] objList = new Object[] {null, 1, 1l, 1.0};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Integer[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Long[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Decimal[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Double[]);

        // long
        objList = new Object[] {null, 1l, 1, 1.0};
        System.assertEquals(false, CollectionUtils.convertObjectList(objList) instanceof Integer[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Long[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Decimal[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Double[]);

        // decimal / double
        objList = new Object[] {null, 1.0, 1, 1l};
        System.assertEquals(false, CollectionUtils.convertObjectList(objList) instanceof Integer[]);
        System.assertEquals(false, CollectionUtils.convertObjectList(objList) instanceof Long[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Decimal[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Double[]);

        // String
        objList = new Object[] {null, 'test'};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof String[]);

        // Id
        objList = new Object[] {null, IdUtils.newId(Account.SObjectType)};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Id[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof String[]);

        // Boolean
        objList = new Object[] {null, true, false};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Boolean[]);

        // Blob
        objList = new Object[] {null, Blob.valueOf('test')};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Blob[]);

        // Date
        objList = new Object[] {null, Date.today(), DateTime.now()};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Date[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof DateTime[]);

        // DateTime
        objList = new Object[] {null, DateTime.now(), Date.today()};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof DateTime[]);

        // Time
        objList = new Object[] {null, Time.newInstance(0, 0, 0, 0)};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Time[]);

        // SObject
        objList = new Object[] {null, new Account()};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof SObject[]);
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) instanceof Account[]);

        // unable to convert these types - assert list is same reference
        // null
        objList = new Object[] {null, null, null};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
        // list
        objList = new Object[] {null, new List<String>()};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
        // set
        objList = new Object[] {null, new Set<String>()};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
        // map
        objList = new Object[] {null, new Map<String, String>()};
        System.assertEquals(true, CollectionUtils.convertObjectList(objList) == objList);
    }

    class TestComparable implements Comparable {
        public Integer value {get; set;}

        public TestComparable(Integer value) {
            this.value = value;
        }

        public Integer compareTo(Object compareTo) {
            TestComparable compareToObj = (TestComparable)compareTo;
            if (this.value == compareToObj.value) {
                return 0;
            } else if (this.value > compareToObj.value) {
                return 1;
            }
            return -1;
        }
    }
}