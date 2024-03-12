<template>
  <div class="documents-table-container">

    <div class="card">
      <!-- Documents Table -->
      <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Documents Table</h6>
        <div class="d-flex">
          <input type="text" v-model="filterText" class="form-control me-2" placeholder="Search By...">
          <a class="btn btn-link text-green px-3 mb-0" @click="openAddDocumentView(document)" href="javascript:;">
            <i class="fas fa-add text-green ms-2" aria-hidden="true"></i>Add Document
          </a>
        </div>
      </div>
      <div class="card-body px-0 pt-0 pb-2">
        <div class="table-responsive p-0">
          <table class="table align-items-center mb-0">
            <thead>
              <tr>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Name
                </th>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">
                  Content Type
                </th>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  File Size
                </th>
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Description
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Creation Date
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(document, index) in documents" :key="index">
                <td>
                  <div class="d-flex px-2 py-1">
                    <div class="d-flex flex-column justify-content-center">
                      <h6 class="mb-0 text-sm">{{ document.name }}</h6>
                    </div>
                  </div>
                </td>
                <td>
                  <p class="text-xs font-weight-bold mb-0">{{ document.contentType }}</p>
                </td>
                <td class="align-middle text-center ">
                  <span class="text-xs font-weight-bold mb-0">{{ document.fileSize }}</span>
                </td>
                <td class="align-middle text-center ">
                  <span class="text-xs font-weight-bold mb-0">{{ document.description }}</span>
                </td>
                <td class="align-middle text-center">
                  <span class="text-secondary text-xs font-weight-bold">{{ formatDate(document.addedDate) }}</span>
                </td>
                <td class="align-middle">
                  <div class="ms-auto text-end">
                    <a class="btn btn-link text-danger text-gradient px-3 mb-0" @click="showConfirmModal(index)"
                      href="javascript:;">
                      <i class="far fa-trash-alt me-2" aria-hidden="true"></i>Delete
                    </a>
                    <a class="btn btn-link text-dark px-3 mb-0" @click="openEditView(document)">
                      <i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i>Edit
                    </a>
                    <a class="btn btn-link text-green px-3 mb-0" @click="openDocumentView(document)"
                      href="javascript:;">
                      <i class="fas fa-eye text-green ms-2" aria-hidden="true"></i>View
                    </a>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Confirmation modal -->
    <ConfirmationModalVue :show="showModal" message="Are you sure you want to delete this document?"
      @confirm="handleConfirm" @cancel="hideModal" />
  </div>
</template>

<script setup>
import ConfirmationModalVue from './ConfirmationModal.vue';
import { useRouter } from 'vue-router';
import { ref, onMounted } from 'vue';
import axios from 'axios';

const documents = ref([]); 
const filterText = ref('');
const showModal = ref(false);
const documentIndexToDelete = ref(null);

const fetchDocuments = async () => {
  try {
    const response = await axios.get('https://localhost:7278/api/Document');
    documents.value = response.data;
  } catch (error) {
    console.error('Error fetching documents:', error);
  }
};
const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString();
};
onMounted(() => {
  fetchDocuments();
});

const router = useRouter();

const openEditView = (document) => {
  router.push({ name: 'edit-view', params: { documentData: document } })
};

const openAddDocumentView = (document) => {
  router.push({ name: 'add-view', params: { documentData: document } })
};

const openDocumentView = (document) => {
  router.push({ name: 'document-view', params: { documentData: document } });
};

const showConfirmModal = (index) => {
  showModal.value = true;
  documentIndexToDelete.value = index;
};

const handleConfirm = () => {
  showModal.value = false;
};

const hideModal = () => {
  showModal.value = false;
};
</script>