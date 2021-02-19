({
    handleItemClicked: function (component, event, helper) {
        const id = event.target.getAttribute('data-id');
        component.getSuper().navigate(id);
    },
});
