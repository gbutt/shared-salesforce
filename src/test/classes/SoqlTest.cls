@IsTest(IsParallel = true)
public class SoqlTest {
    @IsTest
    static void it_should_build_a_big_soql() {
        /* *INDENT-OFF* */
        Soql.Builder builder = Soql.froma('Contact')
            .selecta()
                .fields(new List<String>{'field1', 'field2'})
                .subquery(Soql.froma('Cases')
                    .selecta('CaseNumber')
                    .wherea('Status = \'Open\''))
            .end()
            .wherea()
                .filter('1=1')
                .subqueryFilter('AccountId IN', Soql.froma('Account')
                    .selecta('Id')
                    .wherea('Industry = \'IT\''))
                .startOr()
                    .filter('2=2')
                    .filter('3=3')
                .end()
            .endClause()
            .groupBy()
                .fields(new List<String>{'groupBy1', 'groupBy2'})
            .end()
            .havinga(Soql.Filter.ORA)
                .filter('1=2')
                .startAnd()
                    .filter('2=3')
                    .filter('3=4')
                .end()
            .endClause()
            .orderBy()
                .fields(new List<String>{'orderBy1', 'orderBy2 DESC'})
                .field(Contact.MailingCity, Soql.OrderBy.DESCA)
            .end()
            .limita(100);
        /* *INDENT-ON* */

        String expectedSelect = 'SELECT field1, field2, (SELECT CaseNumber FROM Cases WHERE Status = \'Open\')';
        System.assertEquals(expectedSelect, builder.selectBuilder.build());

        String expectedWhere = 'WHERE 1=1 AND AccountId IN (SELECT Id FROM Account WHERE Industry = \'IT\') AND (2=2 OR 3=3)';
        System.assertEquals(expectedWhere, builder.whereBuilder.build());

        String expectedGroupBy = 'GROUP BY groupBy1, groupBy2';
        System.assertEquals(expectedGroupBy, builder.groupByBuilder.build());

        String expectedHaving = 'HAVING 1=2 OR (2=3 AND 3=4)';
        System.assertEquals(expectedHaving, builder.havingBuilder.build());

        String expectedOrderBy = 'ORDER BY orderBy1, orderBy2 DESC, MailingCity DESC';
        System.assertEquals(expectedOrderBy, builder.orderByBuilder.build());

        System.assertEquals(100, builder.limitValue);

        String expectedSoql = 'SELECT field1, field2, (SELECT CaseNumber FROM Cases WHERE Status = \'Open\')' +
            ' FROM Contact' +
            ' WHERE 1=1 AND AccountId IN (SELECT Id FROM Account WHERE Industry = \'IT\') AND (2=2 OR 3=3)' +
            ' GROUP BY groupBy1, groupBy2' +
            ' HAVING 1=2 OR (2=3 AND 3=4)' +
            ' ORDER BY orderBy1, orderBy2 DESC, MailingCity DESC' +
            ' LIMIT 100';
        System.assertEquals(expectedSoql, builder.build());
        expectedSoql = 'SELECT field1, field2, (SELECT CaseNumber FROM Cases WHERE Status = \'Open\')' +
            '\nFROM Contact' +
            '\nWHERE 1=1' +
            '\n\tAND AccountId IN (SELECT Id FROM Account WHERE Industry = \'IT\')' +
            '\n\tAND (2=2' +
            '\n\t\tOR 3=3)' +
            '\nGROUP BY groupBy1, groupBy2' +
            '\nHAVING 1=2' +
            '\n\tOR (2=3' +
            '\n\t\tAND 3=4)' +
            '\nORDER BY orderBy1, orderBy2 DESC, MailingCity DESC' +
            '\nLIMIT 100';
        System.assertEquals('\n' + expectedSoql, '\n' + builder.build(true));
    }

    @IsTest
    static void it_should_build_a_simple_soql_1() {
        String soql = Soql.froma('Contact')
            .selecta('field1')
            .wherea('1=1')
            .groupBy('groupBy1')
            .havinga('3=3')
            .orderBy('orderBy1')
            .limita(100)
            .build();

        String expectedSoql = 'SELECT field1' +
            ' FROM Contact' +
            ' WHERE 1=1' +
            ' GROUP BY groupBy1' +
            ' HAVING 3=3' +
            ' ORDER BY orderBy1' +
            ' LIMIT 100';
        System.assertEquals(expectedSoql, soql);
    }

    @IsTest
    static void it_should_build_a_simple_soql_2() {
        String soql = Soql.froma('Contact')
            .selecta(new List<String> {'field1', 'field2'})
            .wherea(new List<String> {'1=1', '2=2'}, Soql.Filter.ANDA)
            .groupBy(new List<String> {'groupBy1', 'groupBy2'})
            .havinga(new List<String> {'3=3', '4=4'}, Soql.Filter.ORA)
            .orderBy(new List<String> {'orderBy1', 'orderBy2 DESC'})
            .limita(100)
            .build();

        String expectedSoql = 'SELECT field1, field2' +
            ' FROM Contact' +
            ' WHERE 1=1 AND 2=2' +
            ' GROUP BY groupBy1, groupBy2' +
            ' HAVING 3=3 OR 4=4' +
            ' ORDER BY orderBy1, orderBy2 DESC' +
            ' LIMIT 100';
        System.assertEquals(expectedSoql, soql);
    }

    @IsTest
    static void it_should_build_a_simple_soql_3() {
        String soql = Soql.froma(Contact.getSObjectType())
            .selecta(Contact.Id)
            .wherea('1=1')
            .groupBy(Contact.LastName)
            .havinga('3=3')
            .orderBy(Contact.FirstName)
            .limita(100)
            .build();

        String expectedSoql = 'SELECT Id' +
            ' FROM Contact' +
            ' WHERE 1=1' +
            ' GROUP BY LastName' +
            ' HAVING 3=3' +
            ' ORDER BY FirstName' +
            ' LIMIT 100';
        System.assertEquals(expectedSoql, soql);
    }

    @IsTest
    static void it_should_build_a_simple_soql_4() {
        String soql = Soql.froma(Contact.getSObjectType())
            .selecta(new List<SObjectField> {Contact.Id, Contact.Title})
            .wherea(new List<String> {'1=1', '2=2'})
            .groupBy(new List<SObjectField> {Contact.LastName, Contact.FirstName})
            .havinga(new List<String> {'3=3', '4=4'})
            .orderBy(new List<SObjectField> {Contact.Email, Contact.Description})
            .limita(100)
            .build();

        String expectedSoql = 'SELECT Id, Title' +
            ' FROM Contact' +
            ' WHERE 1=1 AND 2=2' +
            ' GROUP BY LastName, FirstName' +
            ' HAVING 3=3 AND 4=4' +
            ' ORDER BY Email, Description' +
            ' LIMIT 100';
        System.assertEquals(expectedSoql, soql);
    }

    @IsTest
    static void it_should_build_a_simple_soql_5() {
        String soql = Soql.froma(Contact.getSObjectType())
            .selecta(Contact.Id)
            .selecta(Contact.Title)
            .wherea('1=1')
            .wherea('2=2')
            .groupBy(Contact.LastName)
            .groupBy(Contact.FirstName)
            .havinga('3=3')
            .havinga('4=4')
            .orderBy(Contact.Email)
            .orderBy(Contact.Description, Soql.OrderBy.DESCA)
            .limita(100)
            .build();

        String expectedSoql = 'SELECT Id, Title' +
            ' FROM Contact' +
            ' WHERE 1=1 AND 2=2' +
            ' GROUP BY LastName, FirstName' +
            ' HAVING 3=3 AND 4=4' +
            ' ORDER BY Email, Description DESC' +
            ' LIMIT 100';
        System.assertEquals(expectedSoql, soql);
    }
}