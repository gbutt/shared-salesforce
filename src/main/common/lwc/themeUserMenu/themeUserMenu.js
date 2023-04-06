import { LightningElement, api, track } from 'lwc';
import userId from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';

// TODO: replace with LDS. This method queries data from the current user
// import getMenuData from '@salesforce/apex/CustomProfileMenuController.getMenuData';

const basePathWoS = basePath.replace('/s', '');
const menuOverrides = [
    { label: 'My Profile', id: 'profile', href: basePathWoS + '/s/profile/' + userId },
    { label: 'My Settings', id: 'settings', href: basePathWoS + '/s/settings/' + userId },
    {
        label: 'Experience Builder',
        id: 'experienceBuilder',
        href: basePathWoS + '/sfsites/picasso/core/config/commeditor.jsp',
    },
    {
        label: 'Logout',
        id: 'logout',
        href:
            basePathWoS +
            '/secur/logout.jsp?retUrl=' +
            encodeURIComponent(window.location.origin + basePathWoS),
    },
];

export default class ThemeUserMenu extends LightningElement {
    @api
    get menuItems() {
        return this._menuItems;
    }
    set menuItems(value) {
        this._menuItems = value;
        this.buildMenu();
    }
    _menuItems;

    @track navMenu = [];
    isGuestUser = isGuest;
    userProfilePhotoUrl = '';
    userFullName = '';
    userType = '';
    loginHref = basePathWoS + '/s/login';

    connectedCallback() {
        // getMenuData().then((menuData) => {
        //     this.userProfilePhotoUrl = menuData.user.SmallPhotoUrl;
        //     this.userFullName = menuData.user.Name;
        //     this.userType = menuData.user.UserType;
        //     this.buildMenu();
        // });
    }

    handleMenuClicked(event) {
        const menuCmp = this.template.querySelector('.sai-user-menu_menu-trigger-target');
        menuCmp.classList.toggle('slds-hide');
        menuCmp.focus();
    }

    handleMenuBlurred(event) {
        // modern browsers
        if (
            event.relatedTarget &&
            event.relatedTarget.classList.contains('sai-user-menu_no-hide')
        ) {
            return;
        }
        // IE11
        else if (document.activeElement.tagName === 'C-THEME-USER-MENU') {
            return;
        }
        this.hideMenu();
    }

    handleMenuItemClicked(event) {
        this.hideMenu();
        const menuCmp = this.template.querySelector('.sai-user-menu_menu-trigger');
        menuCmp.focus();

        const dataId = event.target.getAttribute('data-id');
        if (menuOverrides.map((item) => item.id).indexOf(dataId) === -1) {
            this.dispatchEvent(
                new CustomEvent('navigate', {
                    detail: {
                        menuItemId: event.target.getAttribute('data-id'),
                    },
                })
            );
        }
    }

    handleLoginClicked(event) {
        const currentPage = location.pathname + location.search;
        const loginHref = this.loginHref + '?startURL=' + encodeURIComponent(currentPage);
        try {
            // modern browsers
            location.assign(loginHref);
        } catch (err) {
            // IE11
            window.navigate(loginHref);
        }
    }

    hideMenu() {
        const menuCmp = this.template.querySelector('.sai-user-menu_menu-trigger-target');
        menuCmp.classList.add('slds-hide');
    }

    buildMenu() {
        const navMenu = this._menuItems
            .filter((item) => {
                if (item.label === 'Experience Builder') {
                    return this.userType === 'Standard';
                }
                return true;
            })
            .map((item) => {
                return (
                    menuOverrides.find((overrideItem) => overrideItem.label === item.label) || {
                        id: item.id,
                        label: item.label,
                        href: 'javascript:void(0);',
                    }
                );
            });
        this.navMenu = navMenu;
    }
}
