import { LightningElement, wire, track, api } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class AccountLookup extends LightningElement {
    @track selectedAccountId;
    @track accountOptions = [];
    @api contactInfo;
    @api firstName;
    @api lastName;

    handleChange(event) {
        this.selectedAccountId = event.detail.value;
        const selectedEvent = new CustomEvent('selected', { detail: this.selectedAccountId });
        this.dispatchEvent(selectedEvent);
    }

    handleFocus() {
        console.log('firstName: ' + this.firstName);
        console.log('lastName: ' + this.lastName);
        getAccounts({ firstName: this.firstName, lastName: this.lastName })
            .then(result => {
                this.accountOptions = result.map(account => ({
                    label: account.Name,
                    value: account.Id
                }));
            })
            .catch(error => {
             
                // if (error) {
                //     if (Array.isArray(error.body)) {
                //         this.errorMsg = error.body.map(e => e.message).join(', ');
                //     } else if (typeof error.body.message === 'string') {
                //         this.errorMsg = error.body.message;
                //     }
                // }
            })
    }
}
