import { LightningElement } from 'lwc';
import LightningDatatable from 'lightning/datatable';
import customCheckbox from './customCheckbox.html';
import customTextArea from './customTextArea.html';

export default class CustomLightningTable extends LightningDatatable {
    static customTypes = {
        customCheckbox: {
            template: customCheckbox,
            standardCellLayout: true,
            typeAttributes: ['isSelected','recordid'],
        },
        customTextArea: {
            template: customTextArea,
            standardCellLayout: false,
            typeAttributes: ['description','recordid'],
        }
        // Other types here
    }
    checkboxhandler(event){
        console.log('fired');
    }

}