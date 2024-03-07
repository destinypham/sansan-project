import { LightningElement, track, wire } from 'lwc';
import searchContact from '@salesforce/apex/ContactController.searchContact';
import updateContact from '@salesforce/apex/ContactController.updateContact';
import insertLeads from '@salesforce/apex/ContactController.insertLeads';
import generateData from './generateContact';

const columns = [
    {
        label: 'Full Name',
        fieldName: 'Name'
    }, {
        label: 'Company Name',
        fieldName: 'Company_Name__c',
    }
];

export default class SearchContact extends LightningElement {

    @track searchData = [];
    columns = columns;
    errorMsg = '';
    contactName = '';
    @track isModalOpen = false;
    @track listContactSelected = [];
    @track isModalOpenUpdate = false;
    @track checkboxIds = [];
    @track isModalOpenNewLead = false;
    @track leads = [];
    @track listContactUpdate = [];
    @track messageUpdate = '';


    handleContactName(event) {
        this.errorMsg = '';
        this.contactName = event.currentTarget.value;
    }

    handleCompanyName(event) {
        this.errorMsg = '';
        this.companyName = event.currentTarget.value;
    }

    handleSearch() {
        if (!this.contactName) {
            this.errorMsg = 'Please enter account name to search.';
            this.searchData = undefined;
            return;
        }
        searchContact({ contactName: this.contactName, companyName: this.companyName })
            .then(result => {
                this.searchData = result;
            })
            .catch(error => {
                this.searchData = undefined;
                if (error) {
                    if (Array.isArray(error.body)) {
                        this.errorMsg = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        this.errorMsg = error.body.message;
                    }
                }
            })
    }

    openModal() {
        this.isModalOpen = true;
        this.searchData = generateData({ searchData: this.searchData });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleRowSelection(event) {
        this.listContactSelected = event.detail.selectedRows;
    }

    handleUpdate() {
        this.isModalOpen = false;
        this.isModalOpenUpdate = true;
    }

    closeModalUpdate() {
        this.isModalOpenUpdate = false;
    }

    handleFullNameChange(event) {
        this.errorMsg = '';
        this.contactName = event.currentTarget.value;
    }

    handleChange(event) {
        console.log('listContactUpdate: ' + JSON.stringify(this.listContactSelected));
        const key = parseInt(event.target.dataset.key);
        const newValue = event.target.value;
        const fieldToUpdate = event.target.dataset.field;
        console.log('key: ' + key);
        console.log('value: ' + newValue);
        console.log('field: ' + fieldToUpdate);

        const contactToUpdate = this.listContactUpdate.findIndex(contact => contact.key === key);

        if (contactToUpdate !== -1) {
            if (fieldToUpdate === 'Name') {
                this.listContactUpdate[contactToUpdate].Name = newValue;
            } else if (fieldToUpdate === 'Company_Name__c') {
                this.listContactUpdate[contactToUpdate].Company_Name__c = newValue;
            }
        } else {
            const newContact = {
                key: key,
                Name: fieldToUpdate === 'Name' ? newValue : '',
                Company_Name__c: fieldToUpdate === 'Company_Name__c' ? newValue : '',
                isUpdateName: false,
                isUpdateCompany: false
            };
            this.listContactUpdate.push(newContact);
        }
    }

    handleCheckboxChange(event) {
        const key = parseInt(event.target.dataset.key);
        const isChecked = event.target.checked;
        const fieldToUpdate = event.target.dataset.field;
        console.log('key: ' + key);
        console.log('isChecked: ' + isChecked);
        console.log('fieldToUpdate: ' + isChecked);

        const contactToUpdate = this.listContactUpdate.findIndex(contact => contact.key === key);

        if (contactToUpdate !== -1) {
            if (fieldToUpdate === 'Name') {
                this.listContactUpdate[contactToUpdate].isUpdateName = isChecked;
            } else if (fieldToUpdate === 'Company_Name__c') {
                this.listContactUpdate[contactToUpdate].isUpdateCompany = isChecked;
            }
        } else {
            const newContact = {
                key: key,
                Name: '',
                Company_Name__c: '',
                isUpdateName: fieldToUpdate === 'Name' ? isChecked : false,
                isUpdateCompany: fieldToUpdate === 'Company_Name__c' ? isChecked : false
            };
            this.listContactUpdate.push(newContact);
        }
    }

    handleSave() {
        // Logic to save the data
        console.log('listContactUpdate: ' + JSON.stringify(this.listContactUpdate));
        console.log('listContactSelected1111: ' + JSON.stringify(this.listContactSelected));
        if (this.listContactUpdate.length > 0) {
            this.listContactSelected = this.listContactSelected.map((contact, index) => {
                console.log('index: ' + index);
                console.log('contact: ' + contact);
                let updatedContact = this.listContactUpdate.find(item => item.key === index);
                let name = (updatedContact && updatedContact.isUpdateName && updatedContact.Name !== '') ? updatedContact.Name : contact.Name;
                let companyName = (updatedContact && updatedContact.isUpdateCompany && updatedContact.Company_Name__c !== '') ? updatedContact.Company_Name__c : contact.Company_Name__c;
                return {
                    ...contact,
                    Name: name,
                    Company_Name__c: companyName
                };
            })

        console.log('listContactSelected: ' + JSON.stringify(this.listContactSelected));
        updateContact({ contacts: this.listContactSelected })
            .then(result => {
                this.messageUpdate = result;
            })
            .catch(error => {
                this.messageUpdate = 'Failed';
                if (error && error.body && error.body.message) {
                    this.errorMsg = error.body.message;
                }
            });
        }
    }

    handleBoxChange(event) {
        const key = parseInt(event.target.dataset.key);
        const isChecked = event.target.checked;
        const fieldToUpdate = event.target.dataset.field;
        const newValue = event.target.value;
        console.log('isChecked: ' + isChecked);
        console.log('fieldToUpdate: ' + fieldToUpdate);
        console.log('newValue: ' + newValue);
        console.log('key: ' + key);
        const leadToUpdate = this.leads.findIndex(lead => lead.key === key);

        if (leadToUpdate !== -1) {
            if(!isChecked) {
                this.leads = this.leads.filter(lead => lead.Name !== newValue);
            } else {
                if (fieldToUpdate === 'Name') {
                    this.leads[leadToUpdate].Name = newValue;
                } else if (fieldToUpdate === 'Company') {
                    this.leads[leadToUpdate].Company = newValue;
                }
            }
        } else {
            if(isChecked) {
                const newLead = {
                    key: key,
                    Name: fieldToUpdate == 'Name' ? newValue : '',
                    Company: fieldToUpdate == 'Company' ? newValue : ''
                };
                this.leads.push(newLead);
            }
        }
    }

    handelNewLead() {
        this.isModalOpen = false;
        this.isModalOpenNewLead = true;
    }

    closeModalNewLead() {
        this.isModalOpenNewLead = false;
    }

    handleCreateLead() {
        console.log('leads: ' + JSON.stringify(this.leads));
        let newLeads = this.leads.map(lead => {
            const { key, ...rest } = lead;
            return rest;
        });
        console.log('newLeads: ' + JSON.stringify(newLeads));
        insertLeads({ leads: newLeads })
            .then(result => {
                this.messageUpdate = result;
            })
            .catch(error => {
                this.messageUpdate = 'Failed';
                if (error && error.body && error.body.message) {
                    this.errorMsg = error.body.message;
                }
            });
    }
}