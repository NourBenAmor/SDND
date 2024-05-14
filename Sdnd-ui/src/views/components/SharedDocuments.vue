<template>
  <div class="documents-table-container m-4">
    <div class="card">
      <!-- Documents Table -->
      <div class="card-header d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Documents Shared With Me</h6>
        <div class="d-flex align-items-center">
          <Dropdown v-model="CurrentDocumentState" :options="DocumentStates" optionLabel="name"
            placeholder="DocumentState" class="dropdown w-full md:w-14rem mt-3 mb-3" />
          <InputText class="searchInput" v-model="filterText" type="text" placeholder="Search" />

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
                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Status
                </th>
                <th
                  class="text-uppercase text-secondary text-center align-middle text-xxs font-weight-bolder opacity-7">
                  Description
                </th>
                <th
                  class="text-uppercase text-secondary text-center align-middle text-xxs font-weight-bolder opacity-7">
                  Permissions
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Added Date
                  <button class="btn btn-link btn-sm p-1 m-1" @click="sortByDate">
                    <div class="sorting-icons">
                      <i class="fas fa-sort-up" aria-hidden="true"></i>
                      <i class="fas fa-sort-down" aria-hidden="true"></i>
                    </div>
                  </button>
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Updated At <button class="btn btn-link btn-sm p-1 m-1" @click="sortByDate">
                    <div class="sorting-icons">
                      <i class="fas fa-sort-up m-0 p-0" aria-hidden="true"></i>
                      <i class="fas fa-sort-down" aria-hidden="true"></i>
                    </div>
                  </button>
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Author
                </th>
                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody v-if="IsLoading">
              <td>
                <skeleton />
              </td>
              <td>
                <skeleton />
              </td>
              <td>
                <skeleton />
              </td>
              <td>
                <skeleton />
              </td>
              <td>
                <skeleton />
              </td>
              <td>
                <skeleton />
              </td>
            </tbody>
            <tbody v-else-if="paginatedAndFilteredDocuments.length > 0">
              <tr v-for="(document, index) in paginatedAndFilteredDocuments" :key="index">
                <td>
                  <div class="d-flex px-2 py-1">
                    <div class="d-flex flex-column justify-content-center">
                      <h6 class="mb-0 text-sm">{{ document.name }}</h6>
                    </div>
                  </div>
                </td>

                <td class="align-middle text-center text-sm">
                  <p class="badge badge-md bg-gradient-success fs-20 mx-auto my-auto">
                    {{ getDocumentStateString(document.documentState) }}
                  </p>
                </td>
                <td class="align-middle text-center">
                  <span class="text-wrap d-inline-block" style="max-width: 300px">
                    <span class="text-xs font-weight-bold mb-0">
                      {{
            document.description.length > 35
              ? document.description.slice(0, 35) + "..."
              : document.description
          }}
                      <span v-if="document.description.length > 35" class="view-all">
                        <a href="#" @click="showFullDescription(document.description)">more</a>
                      </span>
                    </span>
                  </span>
                </td>
                <td class="align-middle">
                  <span class="text-secondary text-xs font-weight-bold d-flex">
                    <p v-for="permission in document.permissions" :key="permission"
                      class="badge badge-md badge-pill bg-secondary fs-20 mx-2 my-auto">
                      {{ permission == 1 ? 'View' : '' }}
                      {{ permission == 2 ? 'Edit' : '' }}
                      {{ permission == 3 ? 'Share' : '' }}
                    </p>
                  </span>
                </td>
                <td class="align-middle text-center">
                  <span class="text-secondary text-xs font-weight-bold">{{
            formatDate(document.addedDate)
          }}</span>
                </td>
                <td class="align-middle text-center">
                  <span class="text-secondary text-xs font-weight-bold">{{
              formatDate(document.updatedDate)
            }}</span>
                </td>
                <td class="align-middle text-center">
                  <div class="comment-header">
                    <div class="profile-image"
                      :style="document.ownerProfilePictureUrl ? `background-image: url(${document.ownerProfilePictureUrl})` : `background-color: #007bff`">
                      <span v-if="!document.ownerProfilePictureUrl">{{ document.ownerUsername[0].toUpperCase() }}</span>
                    </div>
                    <div>
                      <h6 class="mb-0 text-sm">{{ document.ownerUsername }}</h6>
                    </div>
                  </div>

                </td>
                <td class="align-middle d-flex">
                  <div class="ms-auto text-end">
                    <button class="btn btn-link text-green px-3 mb-0" @click="openDocumentView(document.id)"
                      v-tooltip.bottom="{
            value: 'open this Document',
            pt: {
              arrow: {
                style: {
                  borderBottomColor: 'var(--primary-color)'
                }
              },
              text: 'bg-primary font-medium'
            }
          }" label="button">
                      <i class="fas fa-eye text-green ms-2 me-2" aria-hidden="true"></i>
                    </button>

                    <Sidebar v-if="docDetailsVisible" v-model:visible="docDetailsVisible" header="Document Details"
                      :documentId="document.id" position="full">
                      <Document @addfile-emit="uploadFile" />
                    </Sidebar>
                    <button class="btn btn-link text-danger text-gradient px-3 mb-0"
                      @click="showConfirmDeleteModal(index)" v-tooltip.bottom="{
            value: 'delete this Document',
            pt: {
              arrow: {
                style: {
                  borderBottomColor: 'var(--danger-color)',

                }
              },
              text: 'bg-primary font-medium'
            },
            style: {
              backgroundColor: 'red',
            }
          }" label="button">
                      <i class="far fa-x me-2" aria-hidden="true"></i>
                    </button>
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
    <ConfirmationModalVue :show="showDeleteModal" message="Do you want to unfollow this document?"
      @confirm="handleDeleteConfirm" @cancel="hideAllModals" />
  </div>
  <SignaturePdf />
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
  <div class="modal fade" id="fullDescriptionModal" tabindex="-1" role="dialog"
    aria-labelledby="fullDescriptionModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="fullDescriptionModalLabel">
            Full Description
          </h5>
          <button type="button" class="close" @click="hideFullDescriptionModal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <p>{{ fullDescription }}</p>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" @click="hideFullDescriptionModal">
            Close
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import Skeleton from "primevue/skeleton";
// import { useRouter } from "vue-router";
import { useStore } from "vuex";
import Dropdown from "primevue/dropdown";
import InputText from "primevue/inputtext";
import Sidebar from "primevue/sidebar";
import { computed, ref, onMounted, watch } from "vue";
import { toast } from "vue3-toastify";
import BaseApiService from "../../services/apiService";
import ConfirmationModalVue from "./ConfirmationModal.vue";
import Document from "./DocumentDetails/Document.vue";
const IsLoading = ref(false);
const documents = ref([]);
const filterText = ref("");
const showDeleteModal = ref(false);
const showAddDocModal = ref(false);
let docDetailsVisible = ref(false);
const filters = ref({
  name: "",
  description: "",
  documentState: null,
  // addedDateBefore: '',
  // addedDateAfter: '',
  // updatedDateBefore: '',
  // updatedDateAfter: ''
});

const documentIndexToDelete = ref(null);
const currentPage = ref(1);
const documentsPerPage = 6;
const sortBy = ref("asc");
// const router = useRouter();
const store = useStore();
const totalDocuments = computed(() => documents.value.length);
const totalPages = computed(() =>
  Math.ceil(totalDocuments.value / documentsPerPage),
);

const CurrentDocumentState = ref(null);
const DocumentStates = ref([
  { name: "Blank", code: 0 },
  { name: "Filled", code: 1 },
  { name: "Shared", code: 2 },
  { name: "Archived", code: 3 },
]);
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

watch(filterText, (newFilterText) => {
  filters.value.name = newFilterText;
  filters.value.description = newFilterText;
  fetchDocuments();
});

watch(CurrentDocumentState, (newVal) => {
  if (newVal.code) {
    filters.value.documentState = newVal.code;
  } else {
    filters.value.documentState = null; // Set to null or any appropriate value when state is not selected
  }
  fetchDocuments();
});

const fullDescription = ref("");

const showFullDescription = (description) => {
  store.state.showOverlay = true;
  fullDescription.value = description;
  const modal = document.getElementById("fullDescriptionModal");
  if (modal) {
    modal.classList.add("show");
    modal.style.display = "block";
  }
};

const hideFullDescriptionModal = () => {
  store.state.showOverlay = false;
  const modal = document.getElementById("fullDescriptionModal");
  if (modal) {
    modal.classList.remove("show");
    modal.style.display = "none";
  }
};
const paginatedAndFilteredDocuments = computed(() => {
  // const filtered = documents.value.filter((document) =>
  //   document.name.toLowerCase().includes(filterText.value.toLowerCase())
  // );
  const filtered = documents.value;
  const startIndex = (currentPage.value - 1) * documentsPerPage;
  const endIndex = startIndex + documentsPerPage;
  return filtered.slice(startIndex, endIndex);
});
const fetchDocuments = async () => {
  IsLoading.value = true
  try {
    const response = await BaseApiService(`Document/SharedWithMe`).list({
      params: filters.value,
    });
    documents.value = response.data;
    IsLoading.value = false;
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



async function uploadFile(documentId, file) {
  try {
    const formData = new FormData();
    formData.append("DocumentId", documentId);
    formData.append("File", file);
    await BaseApiService(`File/upload`).create(formData);
    toast.success(`"${file.FileName} Uploaded Successfully !"`, {
      autoClose: 1000,
      position: toast.POSITION.BOTTOM_RIGHT,
    });
  } catch (e) {
    toast.error("Error Uploading File", {
      autoClose: 1000,
      position: toast.POSITION.BOTTOM_RIGHT,
    });
  }
}
async function openDocumentView(id) {

  store.state.documentId = id; // Update state
  await new Promise((resolve) => setTimeout(resolve, 0)); // Wait for a tick
  docDetailsVisible.value = true;
}

const showConfirmDeleteModal = (index) => {
  showDeleteModal.value = true;
  store.state.showOverlay = true;
  documentIndexToDelete.value = index;
};
const getDocumentStateString = (documentState) => {
  switch (documentState) {
    case 0:
      return "Blank";
    case 1:
      return "Filled";
    case 2:
      return "Shared";
    case 3:
      return "Archived";
  }
};
const handleDeleteConfirm = async () => {
  try {
    const documentId = documents.value[documentIndexToDelete.value].id;
    await BaseApiService(`Document/Delete`).remove(documentId);
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
};

const hideAllModals = () => {
  hideDeleteModal();
  showAddDocModal.value = false;
};
watch(
  () => store.state.showOverlay,
  (newVal, oldVal) => {
    if (newVal === false && oldVal === true) {
      hideAllModals();
    }
  },
  { immediate: true },
);

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


// actions of a particular document
// const items = [
//   {
//     label: 'Unfollow',
//     command: () => {
//       this.$toast.add({ severity: 'success', summary: 'Updated', detail: 'Data Updated', life: 3000 });
//     }
//   },
//   {
//     label: 'Delete',
//     command: (index) => {
//       showConfirmDeleteModal(index);
//     }
//   },
//   { label: 'Upload', to: '/fileupload' }
// ];

// const open = (id) => {
//   openDocumentView(id);
// };
</script>

<style scoped>
.sorting-icons {
  display: flex;
  flex-direction: column;
}

.dropdown,
.searchInput {
  height: 40px;
  margin-right: 10px;
  border-radius: 10px;
}

#fullDescriptionModal {
  z-index: 100001;
}

.comment-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.profile-image {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-size: cover;
  background-position: center;
  color: #f2f2f2;
  font-size: 16px;
  font-weight: bold;
  margin-right: 10px;
  margin-top: 5px;
  padding-top: 3px;
}
</style>
../../services/apiService
