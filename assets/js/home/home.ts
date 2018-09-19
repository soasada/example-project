// here we have bootstrap imported, thanks to createSharedEntry in webpack.config.js

jQuery(function () {
    let selectorExample = $('#selector-example');
    let selectorData = [{'code': 'foo', 'name': 'FOO'}, {'code': 'bar', 'name': 'BAR'}];

    for (let obj of selectorData) {
        let contents = "<option value='" + obj.code + "'>" + obj.name + "</option>";
        selectorExample.append(contents);
    }

    selectorExample.selectpicker('refresh');
});
