({
    handleNavigation: function (component, event) {
        var id = event.getParam('menuItemId');
        if (id) {
            component.getSuper().navigate(id);
        }
    },
});
