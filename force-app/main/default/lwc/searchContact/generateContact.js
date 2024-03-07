export default function generateData(searchData) {
    return searchDataList.map(searchData => ({
        'Full Name': searchData.Name,
        'Company Name': searchData.Company_Name__c
    }));
}
