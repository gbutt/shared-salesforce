public virtual class EmailBuilder {
    private static final Logger log = LoggerFactory.getInstance(EmailBuilder.class);

    @TestVisible
    public Messaging.SingleEmailMessage email {
        get;
        private set;
    }

    public EmailBuilder() {
        email = new Messaging.SingleEmailMessage();
    }

    public EmailBuilder withToAddress(String value) {
        List<String> toAddresses = email.getToAddresses();
        if (toAddresses == null) {
            toAddresses = new List<String>();
        }
        if (toAddresses.indexOf(value) == -1) {
            toAddresses.add(value);
            email.settoAddresses(new List<String>(toAddresses));
        }
        return this;
    }

    public EmailBuilder withCcAddress(String value) {
        List<String> ccAddresses = email.getCcAddresses();
        if (ccAddresses == null) {
            ccAddresses = new List<String>();
        }
        if (ccAddresses.indexOf(value) == -1) {
            ccAddresses.add(value);
            email.setCcAddresses(new List<String>(ccAddresses));
        }
        return this;
    }

    public EmailBuilder withSubject(String value) {
        if (OrgUtils.isSandbox) {
            email.setSubject('SANDBOX: ' + value);
        } else {
            email.setSubject(value);
        }

        return this;
    }

    public EmailBuilder withPlainTextBody(String value) {
        email.setPlainTextBody(value);
        return this;
    }

    public EmailBuilder withReplyTo(String value, String displayName) {
        email.setReplyTo(value);
        email.setSenderDisplayName(displayName);
        return this;
    }

    public EmailBuilder withTemplateId(Id templateId) {
        email.setTemplateId(templateId);
        return this;
    }

    public EmailBuilder withTargetObjectId(Id targetObjectId) {
        email.setTargetObjectId(targetObjectId);
        return this;
    }

    public EmailBuilder withWhatId(Id whatId) {
        email.setWhatId(whatId);
        return this;
    }

    public EmailBuilder withOrgWideEmailAddressId(Id orgWideEmailAddressId) {
        email.setOrgWideEmailAddressId(orgWideEmailAddressId);
        return this;
    }

    public EmailBuilder withSaveAsActivity(Boolean saveAsActivity) {
        email.setSaveAsActivity(saveAsActivity);
        return this;
    }

    public virtual void sendEmail() {
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    public virtual void sendEmailNoError() {
        try {
            sendEmail();
        } catch (EmailException ex) {
            log.error(ex);
        }
    }
}