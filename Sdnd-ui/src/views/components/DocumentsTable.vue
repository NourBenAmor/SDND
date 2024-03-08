<template>
  <div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h6 class="mb-0">Documents Table</h6>
      <div class="d-flex">
        <!-- Filter Input -->
        <input type="text" v-model="filterText" class="form-control me-2" placeholder="Search By...">
      </div>
    </div>
    <div class="card-body px-0 pt-0 pb-2">
      <div class="table-responsive p-0">
        <table class="table align-items-center mb-0">
          <thead>
            <tr>
              <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                Title
              </th>
              <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">
                Type
              </th>
              <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                Status
              </th>
              <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                Creation Date
              </th>
              <th class="text-secondary opacity-7"></th>
            </tr>
          </thead>
          <tbody>
            <!-- Document rows -->
            <tr v-for="(document, index) in documents" :key="index">
              <td>
                <div class="d-flex px-2 py-1">
                  <div class="d-flex flex-column justify-content-center">
                    <h6 class="mb-0 text-sm">{{ document.title }}</h6>
                  </div>
                </div>
              </td>
              <td>
                <p class="text-xs font-weight-bold mb-0">{{ document.type }}</p>
              </td>
              <td class="align-middle text-center text-sm">
                <span class="badge badge-sm bg-gradient-success">{{ document.status }}</span>
              </td>
              <td class="align-middle text-center">
                <span class="text-secondary text-xs font-weight-bold">{{ document.creationDate }}</span>
              </td>
              <td class="align-middle">
                <div class="ms-auto text-end">
                  <a class="btn btn-link text-danger text-gradient px-3 mb-0" @click="showConfirmModal(index)" href="javascript:;">
                    <i class="far fa-trash-alt me-2" aria-hidden="true"></i>Delete
                  </a>
                  <a class="btn btn-link text-dark px-3 mb-0" @click="openEditView(document)">
                    <i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i>Edit
                  </a>
                  <a class="btn btn-link text-green px-3 mb-0" @click="openDocumentView(document)" href="javascript:;">
                    <i class="fas fa-eye text-green ms-2" aria-hidden="true"></i>View
                  </a>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <ConfirmationModalVue 
      :show="showModal" 
      message="Are you sure you want to delete this document?" 
      @confirm="deleteDocument" 
      @cancel="hideModal" 
    />
  </div>
</template>

<script>
import ConfirmationModalVue from './ConfirmationModal.vue';
export default {
  components: {
    ConfirmationModalVue
  },
  data() {
    return {
      filterText: '',
      showModal: false, 
      documentIndexToDelete: null,
      documents: [ 
        {
          title: 'John Michael',
          type: 'PDF',
          status: 'Online',
          creationDate: '23/04/18',
        },
        {
          title: 'Jane Doe',
          type: 'JPG',
          status: 'Offline',
          creationDate: '25/04/18',
        }
      ]
    };
  },
  methods: {
    openEditView(document) {
      this.$router.push({ name: 'edit-view', params: { documentData: document } });
    },
    openDocumentView(document) {
      this.$router.push({ name: 'document-view', params: { documentData: document } });
    },
    showConfirmModal(index) {
      this.showModal = true; 
      this.documentIndexToDelete = index; 
    },
    hideModal() {
      this.showModal = false;
    },
    deleteDocument() {
      if (this.documentIndexToDelete !== null) {
        this.documents.splice(this.documentIndexToDelete, 1); 
        this.hideModal(); 
      }
    }
  }
};
</script>
