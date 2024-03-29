import { LightningElement, track } from 'lwc';
import newContact from '@salesforce/apex/ContactController.newContact';

export default class LookupWithFilter extends LightningElement {
    @track accountId = '';
    @track firstName = '';
    @track lastName = '';
    @track message = '';

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleChange(event) {
        this.accountId = event.detail.recordId;
    }

    handleSave() {
        newContact({ firstName: this.firstName, lastName: this.lastName, accountId: this.accountId })
        .then(result => {
            console.log(result);
            this.message = result ? 'Successfully!' : 'Failed!';
        })
        .catch(error => {
            console.log('error: ' + error);
        });
    }
}