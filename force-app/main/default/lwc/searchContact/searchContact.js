import { LightningElement, track, wire } from 'lwc';
import searchContact from '@salesforce/apex/ContactController.searchContact';
import updateContact from '@salesforce/apex/ContactController.updateContact';
import insertLeads from '@salesforce/apex/ContactController.insertLeads';
import getContact from '@salesforce/apex/ContactController.getContact';

const columns = [
    {
        label: 'Contact External Id',
        fieldName: 'id'
    }, {
        label: 'Contact Name',
        fieldName: 'name',
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
    @track showButton = false;
    @track selectedContactIds = [];
    @track showButtonNewLead = false;

    @wire(getContact)
    wiredContacts({ error, data }) {
        if (data) {
            this.searchData = data.map(contact => ({ name: contact.name, id: contact.id }));
        } else if (error) {
            console.error('Error retrieving contacts:', error);
        }
    }

    handleContactName(event) {
        this.errorMsg = '';
        this.contactName = event.currentTarget.value;
    }

    /*handleCompanyName(event) {
        this.errorMsg = '';
        this.companyName = event.currentTarget.value;
    }*/

    handleSearch() {
        this.searchData = [];
        if (!this.contactName) {
            this.errorMsg = 'Please enter account name to search.';
            this.searchData = undefined;
            return;
        }
        searchContact({ contactName: this.contactName})
            .then(result => {
                this.searchData = result.map(contact => ({ name: contact.name, id: contact.id }));
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
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedContactIds = [];
        this.isModalOpenUpdate = false;
        this.showButtonNewLead = false;
        this.showButton = false;
    }

    handleRowSelection(event) {
        this.listContactSelected = event.detail.selectedRows;
        this.showButton = true;
        console.log('listContactSelected: ' + this.listContactSelected);
        if(this.listContactSelected.length == 0) {
            this.showButton = false;
            this.showButtonNewLead = false;
        }
    }

    handleUpdate() {
        this.isModalOpen = false;
        this.isModalOpenUpdate = true;
        this.selectedContactIds = [];
    }

    closeModalUpdate() {
        this.isModalOpenUpdate = false;
        this.isModalOpen = true;
        console.log(JSON.stringify(this.listContactSelected));
        this.listContactSelected.forEach(row => {
            if (!this.selectedContactIds.includes(row.Id)) {
                this.selectedContactIds.push(row.Id);
            }
        });
    }

    handelAssociation() {
        this.showButtonNewLead = true;
    }

    handleFullNameChange(event) {
        this.errorMsg = '';
        this.contactName = event.currentTarget.value;
    }

    handleChange(event) {
        const key = parseInt(event.target.dataset.key);
        const newValue = event.target.value;
        const fieldToUpdate = event.target.dataset.field;

        const contactToUpdate = this.listContactUpdate.findIndex(contact => contact.key === key);

        if (contactToUpdate !== -1) {
            if (fieldToUpdate === 'name') {
                this.listContactUpdate[contactToUpdate].name = newValue;
            }
        } else {
            const newContact = {
                key: key,
                id: '',
                name: fieldToUpdate === 'name' ? newValue : '',
                isUpdateId: false,
                isUpdateName: false
            };
            this.listContactUpdate.push(newContact);
        }
    }

    handleCheckboxChange(event) {
        const key = parseInt(event.target.dataset.key);
        const isChecked = event.target.checked;
        const fieldToUpdate = event.target.dataset.field;
        const newValue = event.target.value;

        const contactToUpdateIndex = this.listContactUpdate.findIndex(contact => contact.key === key);

        if (contactToUpdateIndex !== -1) {
            if (fieldToUpdate === 'id') {
                this.listContactUpdate[contactToUpdateIndex].id = isChecked ? newValue : '';
                this.listContactUpdate[contactToUpdateIndex].isUpdateId = isChecked;
            } else if (fieldToUpdate === 'name') {
                this.listContactUpdate[contactToUpdateIndex].name = isChecked ? newValue : '';
                this.listContactUpdate[contactToUpdateIndex].isUpdateName = isChecked;
            }
        } else {
            const newContact = {
                key: key,
                id: fieldToUpdate === 'id' && isChecked ? newValue : '',
                name: fieldToUpdate === 'name' && isChecked ? newValue : '',
                isUpdateId: fieldToUpdate === 'id' ? isChecked : false,
                isUpdateName: fieldToUpdate === 'name' ? isChecked : false
            };
            this.listContactUpdate.push(newContact);
        }
    }

    handleSave() {
        if (this.listContactUpdate.length > 0) {
            this.listContactSelected = this.listContactSelected.map((contact, index) => {
                let updatedContact = this.listContactUpdate.find(item => item.key === index);
                let id = (updatedContact && updatedContact.isUpdateId && updatedContact.id !== '') ? updatedContact.id : '';
                let name = (updatedContact && updatedContact.isUpdateName && updatedContact.name !== '') ? updatedContact.name : '';
                return {
                    ...contact,
                    id: id,
                    name: name
                };
            })
        const contacts = this.listContactSelected;
        updateContact({ contacts: contacts })
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
                this.leads = this.leads.filter(lead => lead.id !== newValue);
            } else {
                if (fieldToUpdate === 'id') {
                    this.leads[leadToUpdate].Id = newValue;
                } else if (fieldToUpdate === 'name') {
                    this.leads[leadToUpdate].Name = newValue;
                }
            }
        } else {
            if(isChecked) {
                const newLead = {
                    key: key,
                    Id: fieldToUpdate == 'id' ? newValue : '',
                    Name: fieldToUpdate == 'name' ? newValue : ''
                };
                this.leads.push(newLead);
            }
        }
        console.log(JSON.stringify(this.leads));
    }

    handelNewLead() {
        this.isModalOpen = false;
        this.isModalOpenNewLead = true;
        this.selectedContactIds = [];
    }

    closeModalNewLead() {
        this.isModalOpenNewLead = false;
        this.isModalOpen = true;
        console.log(JSON.stringify(this.listContactSelected));
        this.listContactSelected.forEach(row => {
            if (!this.selectedContactIds.includes(row.Id)) {
                this.selectedContactIds.push(row.Id);
            }
        });
        console.log(JSON.stringify(this.selectedContactIds));
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