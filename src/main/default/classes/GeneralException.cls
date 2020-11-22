public virtual class GeneralException extends Exception {
    public override String getStackTraceString() {
        if (super.getCause() != null) {
            return super.getCause().getStackTraceString();
        }
        return super.getStackTraceString();
    }
}