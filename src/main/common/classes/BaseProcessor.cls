public abstract class BaseProcessor {
    protected abstract void doExecute();

    protected virtual void initialize() {}
    protected virtual void preValidation() {}
    protected virtual void postValidation() {}
    protected virtual void finalize() {}
    protected virtual Boolean shouldExecute() {
        return true;
    }

    public virtual void execute() {
        initialize();
        preValidation();
        if (!shouldExecute()) {
            return;
        }
        doExecute();
        postValidation();
        finalize();
    }
}