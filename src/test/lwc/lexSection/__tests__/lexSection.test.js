import { createElement } from 'lwc';
import LexSection from 'c/lexSection';

describe('c-lex-section', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('should default to opened', () => {
        const element = createElement('c-lex-section', {
            is: LexSection,
        });
        document.body.appendChild(element);
        expect(element.sectionState).toEqual('opened');
        assertIsOpened(element);
    });

    it('should update to closed', async () => {
        const element = createElement('c-lex-section', {
            is: LexSection,
        });
        document.body.appendChild(element);

        element.sectionState = 'closed';
        expect(element.sectionState).toEqual('closed');

        await Promise.resolve();
        assertIsClosed(element);
    });

    it('should close when header clicked', async () => {
        const element = createElement('c-lex-section', {
            is: LexSection,
        });
        document.body.appendChild(element);

        expect(element.sectionState).toEqual('opened');
        element.shadowRoot.querySelector('button').click();
        expect(element.sectionState).toEqual('closed');

        await Promise.resolve();
        assertIsClosed(element);
    });

    it('should open when header clicked', async () => {
        const element = createElement('c-lex-section', {
            is: LexSection,
        });
        document.body.appendChild(element);

        element.sectionState = 'closed';
        await Promise.resolve();

        expect(element.sectionState).toEqual('closed');
        element.shadowRoot.querySelector('button').click();
        expect(element.sectionState).toEqual('opened');

        await Promise.resolve();
        assertIsOpened(element);
    });
});

function assertIsOpened(element) {
    const iconEl = element.shadowRoot.querySelector('lightning-icon');
    expect(iconEl.iconName).toEqual('utility:chevrondown');
    const contentEl = element.shadowRoot.querySelector('div.slds-section__content');
    expect(Array.from(contentEl.classList)).not.toContain('slds-hide');
}

function assertIsClosed(element) {
    const iconEl = element.shadowRoot.querySelector('lightning-icon');
    expect(iconEl.iconName).toEqual('utility:chevronright');
    const contentEl = element.shadowRoot.querySelector('div.slds-section__content');
    expect(Array.from(contentEl.classList)).toContain('slds-hide');
}
