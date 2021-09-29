@isTest(IsParallel = true)
private class EmailBuilderTest {
    @isTest
    static void it_should_add_to_address() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        builder.withToAddress('bwillis@email.org');

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"toAddresses":["bwillis@email.org"]'), jsonEmail);

        // When
        builder.withToAddress('bwillis@email.org');

        // Then - no duplicates
        jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"toAddresses":["bwillis@email.org"]'), jsonEmail);

        // When
        builder.withToAddress('cwillis@email.org');

        // Then
        jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"toAddresses":["bwillis@email.org","cwillis@email.org"]'), jsonEmail);
    }

    @isTest
    static void it_should_add_cc_address() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        builder.withCcAddress('bwillis@email.org');

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"ccAddresses":["bwillis@email.org"]'), jsonEmail);

        // When
        builder.withCcAddress('bwillis@email.org');

        // Then - no duplicates
        jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"ccAddresses":["bwillis@email.org"]'), jsonEmail);

        // When
        builder.withCcAddress('cwillis@email.org');

        // Then
        jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"ccAddresses":["bwillis@email.org","cwillis@email.org"]'), jsonEmail);
    }

    @isTest
    static void it_should_add_subject() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        OrgUtils.isSandbox = true;
        builder.withSubject('bwillis@email.org');

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"subject":"SANDBOX: bwillis@email.org"'), jsonEmail);

        // When
        OrgUtils.isSandbox = false;
        builder.withSubject('bwillis@email.org');

        // Then
        jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"subject":"bwillis@email.org"'), jsonEmail);
    }

    @isTest
    static void it_should_add_plain_text_body() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        builder.withPlainTextBody('bwillis@email.org');

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"plainTextBody":"bwillis@email.org"'), jsonEmail);
    }

    @isTest
    static void it_should_add_reply_to() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        builder.withReplyTo('bwillis@email.org', 'Bruce Willis');

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"replyTo":"bwillis@email.org"'), jsonEmail);
        System.assert(jsonEmail.contains('"senderDisplayName":"Bruce Willis"'), jsonEmail);
    }

    @isTest
    static void it_should_set_template_id() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        builder.withTemplateId(template.Id);

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"templateId":"' + template.Id + '"'), jsonEmail);
    }

    @isTest
    static void it_should_set_target_object_id() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        Id objectId = IdUtils.newId(Contact.getSObjectType());
        builder.withTargetObjectId(objectId);

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"targetObjectId":"' + objectId + '"'), jsonEmail);
    }

    @isTest
    static void it_should_set_what_id() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        Id objectId = IdUtils.newId(Account.getSObjectType());
        builder.withWhatId(objectId);

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"whatId":"' + objectId + '"'), jsonEmail);
    }

    @isTest
    static void it_should_set_org_wide_email_address_id() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        Id objectId = IdUtils.newId(OrgWideEmailAddress.getSObjectType());
        builder.withOrgWideEmailAddressId(objectId);

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"orgWideEmailAddressId":"' + objectId + '"'), jsonEmail);
    }

    @isTest
    static void it_should_set_save_as_activity() {
        // Given
        EmailBuilder builder = new EmailBuilder();

        // When
        builder.withSaveAsActivity(true);

        // Then
        String jsonEmail = JSON.serialize(builder.email);
        System.assert(jsonEmail.contains('"saveAsActivity":true'), jsonEmail);
    }

    @isTest
    static void it_should_send_email_without_error() {
        try {
            new EmailBuilder().sendEmailNoError();
        } catch (Exception ex) {
            System.assert(false, 'Expected no error, received ' + ex);
        }
    }

    @isTest
    static void it_should_send_email_with_error() {
        Exception ex;
        try {
            new EmailBuilder().sendEmail();
        } catch (Exception emailEx) {
            ex = emailEx;
        }
        // Then
        System.assert(ex != null);
    }
}