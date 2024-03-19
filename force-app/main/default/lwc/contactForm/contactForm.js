import { LightningElement, track } from 'lwc';
import newContact from '@salesforce/apex/ContactController.newContact';

export default class ContactForm extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track selectedAccountId;
    @track message;

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleAccountSelection(event) {
        this.selectedAccountId = event.detail;
    }

/*     get contactInfo() {
        return { firstName: this.firstName, lastName: this.lastName };
    } */

    get firstName() {
        return this.firstName;
    }

    get lastName() {
        return this.lastName;
    }

    handleSave() {
        newContact({ firstName: this.firstName, lastName: this.lastName, accountId: this.selectedAccountId })
        .then(result => {
            console.log(result);
            this.message = result ? 'Successfully!' : 'Failed!';
        })
        .catch(error => {
            console.log('error: ' + error);
        });
    }
}