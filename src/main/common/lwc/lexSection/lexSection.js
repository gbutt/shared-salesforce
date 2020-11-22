/*
    A base component that mimics the section accordion on a salesforce record
    Usage:
    <c-lex-section title="The Good Stuff">
        <div class="your-content-goes-here" />
    </c-lex-section>
*/
import { LightningElement, api } from "lwc";

export default class LexSection extends LightningElement {
    @api
    title;

    @api
    get sectionState() {
        return this._sectionState;
    }
    set sectionState(value) {
        this._sectionState = value;
        this.updateView();
    }
    _sectionState = "opened";

    iconName = "utility:chevrondown";

    handleTitleClicked() {
        this.toggleSectionState();
        this.dispatchEvent(new CustomEvent(this.sectionState));
    }

    toggleSectionState() {
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.sectionState =
            this.sectionState === "closed" ? "opened" : "closed";
    }

    getContentEl() {
        return this.template.querySelector(".slds-section__content");
    }

    updateView() {
        if (this.sectionState === "closed") {
            this.iconName = "utility:chevronright";
            this.getContentEl().classList.add("slds-hide");
        } else {
            this.iconName = "utility:chevrondown";
            this.getContentEl().classList.remove("slds-hide");
        }
    }
}
