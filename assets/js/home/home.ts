import 'bootstrap';
import 'bootstrap-select';

jQuery(function () {
    let selectorExample = $('#selector-example');
    let selectorData = [{'code': 'foo', 'name': 'FOO'}, {'code': 'bar', 'name': 'BAR'}];

    for (let obj of selectorData) {
        let contents = "<option value='" + obj.code + "'>" + obj.name + "</option>";
        selectorExample.append(contents);
    }

    selectorExample.selectpicker('refresh');
});
