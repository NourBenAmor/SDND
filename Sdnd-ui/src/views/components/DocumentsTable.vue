<template>
  <div class="documents-table-container">
    <div class="card">
      <!-- Documents Table -->
      <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Documents Table</h6>
        <div class="d-flex align-items-center">
          <input type="text" v-model="filterText" class="form-control me-2" style="height: 38px"
            placeholder="Enter Name" />
          <button class="btn btn-primary px-0 mb-0 d-flex align-items-center text-nowrap px-2 mx-2"
            @click="openAddDocumentView(document)" href="javascript:;">
            <i class="fas fa-add me-2" aria-hidden="true"></i> Add New Document
          </button>
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
                  Document State
                </th>
                <th
                  class="text-uppercase text-secondary text-center align-middle  text-xxs font-weight-bolder opacity-7">
                  Description
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Creation Date
                  <button class="btn btn-link btn-sm" @click="sortByDate">
                    <div class="sorting-icons">
                      <i class="fas fa-sort-up" aria-hidden="true"></i>
                      <i class="fas fa-sort-down" aria-hidden="true"></i>
                    </div>
                  </button>
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody v-if="paginatedAndFilteredDocuments.length > 0">
              <tr v-for="(document, index) in paginatedAndFilteredDocuments" :key="index">
                <td>
                  <div class="d-flex px-2 py-1">
                    <div class="d-flex flex-column justify-content-center">
                      <h6 class="mb-0 text-sm">{{ document.name }}</h6>
                    </div>
                  </div>
                </td>
                <td>
                  <p class="text-xs font-weight-bold mb-0">
                    {{ document.contentType }}
                  </p>
                </td>

                <td class="align-middle text-center text-sm">
                  <p class="badge badge-sm bg-gradient-success">
                    {{ getDocumentStateString(document.documentState) }}
                  </p>
                </td>
                <td class="align-middle text-center">
  <span class="text-wrap d-inline-block" style="max-width: 300px;">
    <span class="text-xs font-weight-bold mb-0">
      {{ document.description.length > 50 ? document.description.slice(0, 50) + '...' : document.description }}
      <span v-if="document.description.length > 50" class="view-all">
        <a href="#" @click="showFullDescription(document.description)">View All</a>
      </span>
    </span>
  </span>
</td>



                <td class="align-middle text-center">
                  <span class="text-secondary text-xs font-weight-bold">{{
                    formatDate(document.addedDate)
                    }}</span>
                </td>
                <td class="align-middle d-flex">
                  <div class="ms-auto text-end">
                    <a class="btn btn-link text-green px-3 mb-0" @click="openDocumentView(document.id)"
                      href="javascript:;">
                      <i class="fas fa-eye text-green ms-2" aria-hidden="true"></i>{{ " " }}View
                    </a>
                    <a class="btn btn-link text-dark px-3 mb-0" @click="openEditView(document.id)">
                      <i class="fas fa-pencil-alt text-dark me-2" aria-hidden="true"></i>Edit
                    </a>

                    <a class="btn btn-link text-danger text-gradient px-3 mb-0" @click="showConfirmDeleteModal(index)"
                      href="javascript:;">
                      <i class="far fa-trash-alt me-2" aria-hidden="true"></i>Delete
                    </a>
                  </div>
                </td>
              </tr>
            </tbody>
            <tbody v-else>
              <tr>
                <td colspan="6" class="text-center">No documents available</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <AddDocument :show="showAddDocModal" @add-newdocument="addDocument" />
    <ConfirmationModalVue :show="showDeleteModal" message="Are you sure you want to delete this document ?"
      @confirm="handleDeleteConfirm" @cancel="hideAllModals" />
  </div>
  <nav aria-label="Page navigation example" class="d-flex justify-content-center">
    <ul class="pagination mt-3">
      <li class="page-item" :class="{ disabled: currentPage === 1 }">
        <a class="page-link" href="#" @click="prevPage">
          <span aria-hidden="true">&laquo;</span>
        </a>
      </li>
      <li class="page-item" v-for="page in totalPages" :key="page" :class="{ active: currentPage === page }">
        <a class="page-link" href="#" @click="changePage(page)">{{ page }}</a>
      </li>
      <li class="page-item" :class="{ disabled: currentPage === totalPages }">
        <a class="page-link" href="#" @click="nextPage">
          <span aria-hidden="true">&raquo;</span>
        </a>
      </li>
    </ul>
  </nav>
  <div class="modal fade" id="fullDescriptionModal" tabindex="-1" role="dialog" aria-labelledby="fullDescriptionModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="fullDescriptionModalLabel">Full Description</h5>
        <button type="button" class="close" @click="hideFullDescriptionModal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>{{ fullDescription }}</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" @click="hideFullDescriptionModal">Close</button>
      </div>
    </div>
  </div>
</div>

</template>

<script setup>
import { useRouter } from "vue-router";
import { useStore } from "vuex";
import { computed, ref, onMounted,watch } from "vue";
import {toast} from 'vue3-toastify';
import BaseApiService from "../../services/apiService";
import AddDocument from "./AddDocument.vue";
import ConfirmationModalVue from "./ConfirmationModal.vue";
const documents = ref([]);
const filterText = ref("");
const showDeleteModal = ref(false);
const showAddDocModal = ref(false);
const documentIndexToDelete = ref(null);
const currentPage = ref(1);
const documentsPerPage = 6;
const sortBy = ref("asc");
const router = useRouter();
const store = useStore();
const totalDocuments = computed(() => documents.value.length);
const totalPages = computed(() =>
  Math.ceil(totalDocuments.value / documentsPerPage)
);

const changePage = (page) => {
  currentPage.value = page;
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++;
  }
};

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--;
  }
};


const fullDescription = ref('');

const showFullDescription = (description) => {
  fullDescription.value = description;
  const modal = document.getElementById('fullDescriptionModal');
  if (modal) {
    modal.classList.add('show');
    modal.style.display = 'block';
  }
};

const hideFullDescriptionModal = () => {
  const modal = document.getElementById('fullDescriptionModal');
  if (modal) {
    modal.classList.remove('show');
    modal.style.display = 'none';
  }
};
const paginatedAndFilteredDocuments = computed(() => {
  const filtered = documents.value.filter((document) =>
    document.name.toLowerCase().includes(filterText.value.toLowerCase())
  );

  const startIndex = (currentPage.value - 1) * documentsPerPage;
  const endIndex = startIndex + documentsPerPage;
  return filtered.slice(startIndex, endIndex);
});
const fetchDocuments = async () => {
  try {
    const response = await BaseApiService(`Document/me`).list();
    console.log(response.data);
    documents.value = response.data;
  } catch (error) {
    console.error("Error fetching documents:", error);
  }
};

const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

onMounted(() => {
  fetchDocuments();
});

const openEditView = (documentId) => {
  router.push({ name: "EditView", params: { id: documentId } });
};

const openAddDocumentView = () => {
  showAddDocModal.value = true;
  store.state.showOverlay = true;
};


async function addDocument(newDoc) {
  try {
    const formData = new FormData();
    formData.append('Name', newDoc.name);
    formData.append('Description', newDoc.description);
    formData.append('contentType', newDoc.contentType);
    formData.append('file', newDoc.file);
    const response = await BaseApiService(`Document/upload`).create(formData);
    await hideAllModals();
    toast.success("Document Added Successfully !", {
      autoClose: 1000,
      position: toast.POSITION.BOTTOM_RIGHT,
    });
    console.log(response.data);
  } catch (e) {
    console.log(e);
  }
}
const openDocumentView = (documentId) => {
  router.push({ name: "document-view", params: { id: documentId } });
};


const showConfirmDeleteModal = (index) => {
  showDeleteModal.value = true;
  store.state.showOverlay = true;
  documentIndexToDelete.value = index;
};
const getDocumentStateString = (documentState) => {
  switch (documentState) {
    case 0:
      return "Uploaded";
    case 1:
      return "OCR Pending";
    case 2:
      return "Signed";
    default:
      return "Unknown";
  }
};
const handleDeleteConfirm = async () => {
  try {
    const documentId = documents.value[documentIndexToDelete.value].id;
    const response = await BaseApiService(`Document/Delete`).remove(documentId);
    console.log(response);
    documents.value.splice(documentIndexToDelete.value, 1);
    hideDeleteModal();
    toast.error("Document Deleted !", {
      autoClose: 1000,
      position: toast.POSITION.BOTTOM_RIGHT,
    });
  } catch (error) {
    console.error("Error deleting document:", error);
  }
};

const hideDeleteModal = () => {
  showDeleteModal.value = false;
  store.state.showOverlay = false;
}

const hideAllModals = () => {
  hideDeleteModal();
  showAddDocModal.value = false;
};
watch(() => store.state.showOverlay, (newVal, oldVal) => {
  if (newVal === false && oldVal === true) {
    hideAllModals();
  }
}, { immediate: true });

const sortByDate = () => {
  if (sortBy.value === "asc") {
    sortBy.value = "desc";
  } else {
    sortBy.value = "asc";
  }

  const sortedDocuments = [...documents.value].sort((a, b) => {
    const dateA = new Date(a.addedDate);
    const dateB = new Date(b.addedDate);
    return sortBy.value === "asc" ? dateA - dateB : dateB - dateA;
  });

  documents.value = sortedDocuments;
};
</script>

<style scoped>
.sorting-icons {
  display: flex;
  flex-direction: column;
}
</style>
../../services/apiService
