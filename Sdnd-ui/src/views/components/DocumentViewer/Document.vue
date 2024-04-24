<template>
  <Splitter style="height: 90vh; " class="m-0">
    <SplitterPanel class="flex align-items-center justify-content-center overflow-auto ">
      <div class="d-flex justify-content-between">
        <TabMenu :model="items">
        </TabMenu>
      </div>
      <div v-if="activeitem == 0">
        <div class="m-5" v-if="!isFetched">
          <Skeleton class="mb-2"></Skeleton>
          <Skeleton width="10rem" class="mb-2"></Skeleton>
          <Skeleton width="5rem" class="mb-2"></Skeleton>
          <Skeleton height="2rem" class="mb-2"></Skeleton>
          <Skeleton width="10rem" height="4rem"></Skeleton>
        </div>
        <form class="m-5" v-else>
          <div class="row">
            <div class="col-12 col-sm-2 bg-white">Title</div>
            <div class="col-12 col-sm-10">{{ DocumentDetails?.name }}</div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Description</div>
            <div class="col-12 col-sm-10">{{ DocumentDetails?.description }}</div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">State</div>
            <div class="col-12 col-sm-10">
              <argon-badge variant="gradient" color="success">
                {{ getDocumentStateString(DocumentDetails?.documentState) }}
              </argon-badge>
            </div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Created at</div>
            <div class="col-12 col-sm-10">
              <argon-badge variant="gradient" color="success">
                {{ formatDate(DocumentDetails?.addedDate) }}
              </argon-badge>
            </div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Last Modified at</div>
            <div class="col-12 col-sm-10">
              <argon-badge variant="gradient" color="success">
                {{ formatDate(DocumentDetails?.updatedDate) }}
              </argon-badge>
            </div>
          </div>
          <div class="row">
            <div v-if="DocumentDetails?.files.length > 0" class="document-files-container card">

              <DataTable :value="DocumentDetails?.files">
                <template #header>
                  <div class="d-flex  align-items-center  justify-content-between">
                    <h6 class="text-xl font-bold p-0 m-0">Document Files</h6>
                    <Button icon="fas fa-plus" label="Add New File" severity="success" @click="fileInput.click()" />
                    <input type="file" ref="fileInput" class="d-none" @change="handleFileUpload" />
                  </div>
                </template>
                <Column v-for="col of FileColumns" :key="col.field" :field="col.field" :header="col.header">
                  <template v-if="col.field === 'actions'" #body="slotProps">
                    <div class="d-flex ml-0">
                      <Button icon="fas fa-eye" class="p-button-rounded p-button-text"
                        @click="viewFile(slotProps.data)" />
                      <Button icon="fas fa-pencil" class="p-button-rounded p-button-text"
                        @click="editFile(slotProps.data)" />
                      <Button icon="fas fa-trash" class="p-button-rounded p-button-text"
                        @click="deleteFile(slotProps.data)" />
                    </div>
                  </template>
                </Column>
                <!-- <Column :key="123456" :field="actions.field" :header="actions.header"></Column> -->
                <!-- <template #footer>
                  <div class="flex justify-content-start">
                    <Button icon="fas fa-plus" label="Add" severity="success" />
                  </div>
                </template> -->
              </DataTable>
            </div>
          </div>
        </form>
      </div>
      <div v-if="activeitem == 1">
        <DocumentEdit :document-id="documentId" docuemnt-states:documentStates />
      </div>
      <div class="m-5" v-if="activeitem == 2">
        <Timeline :value="events">
          <template #opposite="slotProps">
            <small class="p-text-secondary">{{ slotProps.item.date }}</small>
          </template>
          <template #content="slotProps">
            {{ slotProps.item.status }}
          </template>
        </Timeline>
      </div>
      <div v-if="activeitem === 4">
        <div class="m-5">
          <h2>Shared With Me</h2>
          <form @submit.prevent="shareDocument" class="share-form">
            <div class="form-group">
              <label for="username">Username to share with:</label>
              <!-- Autocomplete input -->
              <input type="text" class="form-control smaller-input" v-model="sharedUsername" @input="filterUsernames">
              <!-- Autocomplete dropdown -->
              <div v-if="isFetched && filteredUsernames.length" class="autocomplete-dropdown">
                <div v-for="(username, index) in filteredUsernames" :key="index" @click="selectUsername(username)">
                  {{ username }}
                </div>
              </div>
            </div>
            <button type="submit" class="btn btn-primary">Share Document</button>
          </form>
        </div>
      </div>
    </SplitterPanel>
    <SplitterPanel class="flex align-items-center justify-content-center ">
      <FileView :src="src" />
    </SplitterPanel>
  </Splitter>
</template>

<script setup>
//import VuePdfjs from './VuePdfjs.vue';
import FileView from './FileView.vue';
//import PdfViewer from "./PdfViewer.vue";

import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';
import Timeline from "primevue/timeline";
import DocumentEdit from "../DocumentEdit.vue";
import Skeleton from "primevue/skeleton";
import ArgonBadge from "@/components/ArgonBadge.vue";
import Splitter from "primevue/splitter";
import SplitterPanel from "primevue/splitterpanel";
import { ref, computed } from "vue";
import TabMenu from "primevue/tabmenu";
import BaseApiService from "../../../services/apiService";
import { onMounted } from "vue";
import { useStore } from "vuex";
import { toast } from "vue3-toastify";

//const router = useRouter();
//const route = useRoute();

const fileInput = ref(null);
const fileId = ref('e7171698-1f32-465a-b632-7223c0e09cc0');
const src = ref(`https://localhost:7278/api/document/pdf/${fileId.value}`);

const url = ref('');
url.value = `"/web/viewer.hile${src.value}"`;
const events = ref([
  { status: "", date: "", icon: "", color: "#9C27B0" },
  { status: "", date: "", icon: "", color: "#9C27B0" },
  {
    status: "File Added",
    date: "16/04/2024 16:15",
    icon: "fa-solid fa-pencil-in-square",
    color: "#FF9800",
  },
  {
    status: "Document Created",
    date: "16/04/2024 10:00",
    icon: "fas fa",
    color: "#607D8B",
  },
]);
//const src = ref("https://localhost:7278/api/document/pdf/49c621f7-9749-46df-b419-aae1d45ce60c");
const store = useStore();
const documentId = computed(() => store.state.documentId);
const isFetched = ref("false");
const sharedUsername = ref('');
const shareResult = ref('');
const usernames = ref([]);
const filteredUsernames = ref([]);

// const props = defineProps({
//     documentId: String // Enforce string type for clarity and potential validation
// });
const DocumentDetails = ref(null);
onMounted(() => {
  fetchDocumentDetails(documentId.value);
});
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
const filterUsernames = () => {
  filteredUsernames.value = usernames.value.filter(username => {
    return username.toLowerCase().includes(sharedUsername.value.toLowerCase());
  });
};

const selectUsername = username => {
  sharedUsername.value = username;
  filteredUsernames.value = [];
};
const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString();
};
const fetchDocumentDetails = async (id) => {
  try {
    if (id == null) {
      return;
    }

    const response = await BaseApiService(`Document/${id}`).list();
    console.log(response.data);
    DocumentDetails.value = response.data;
    isFetched.value = true;
  } catch (error) {
    isFetched.value = false;
    console.error("Error fetching document:", error);
  }
};
const fetchUsernames = async () => {
  try {
    const response = await BaseApiService(`Account/usernames`).list();
    console.log(response.data);
    usernames.value = response.data;
    isFetched.value = true;
  } catch (error) {
    console.error('Error fetching usernames:', error);
  }
};
const shareDocument = async () => {
  try {
    const newDoc = { documentId: documentId.value, username: sharedUsername.value };
    const response = await BaseApiService('Document/Share').create(newDoc);
    shareResult.value = response.data;

    // Use the toast object to show a success message
    toast.success("Document Shared Successfully !", {
      duration: 1000, // Auto-close duration in milliseconds
      position: "bottom-right", // Position of the toast message
    });
  } catch (error) {
    shareResult.value = 'Error sharing document';
    console.error('Error sharing document:', error);
  }
};
const activeitem = ref(0);
const items = ref([
  {
    label: "Details",
    icon: "fa-solid fa-bars",
    command: () => {
      activeitem.value = 0;
    },
  },
  {
    label: "Edit",
    icon: "fa-solid fa-pen-to-square",
    command: () => {
      activeitem.value = 1;
    },
  },
  {
    label: "Version History",
    icon: "fas fa-history",
    command: () => {
      activeitem.value = 2;
    },
  },
  {
    label: "Discussions",
    icon: "fa-solid fa-comments",
    command: () => {
      activeitem.value = 3;
    },
  },
  {
    label: "Shared With",
    icon: "fa-solid fa-user-group",
    command: () => {
      activeitem.value = 4;
    },
  },
]);
const emit = defineEmits(['addfile-emit']);
const handleFileUpload = async (event) => {
  const file = event.target.files[0];
  console.log("file upload trigered", documentId.value, file.name);
  await emit('addfile-emit', documentId.value, file);
  fetchDocumentDetails(documentId.value);
};

const FileColumns = [
  { field: 'name', header: 'Name' },
  { field: 'formattedFileSize', header: 'Size' },
  { field: 'filePath', header: 'Path' },
  { field: 'actions', header: 'Actions' }
];

const deleteFile = (file) => {
  // Implement file deletion logic here
  console.log('Deleting file:', file);
};

const editFile = (file) => {
  // Implement file editing logic here
  console.log('Editing file:', file);
};

const viewFile = (file) => {
  // Implement file viewing logic here
  fileId.value = file.id;
  console.log('Viewing file:', file);
};

// import axios from 'axios'; // Or your preferred HTTP library

// const isUploading = ref(false); // Optional flag for upload status

// const handleIframeMessage = async (event) => {
//     if (event.origin !== window.location.origin) {
//         // Handle potential security violations (consider logging or ignoring)
//         return;
//     }

//     const { filename, blobUrl } = event.data;

//     isUploading.value = true; // Set uploading flag (optional)
//     console.log("data got from iframe");
//     console.log("filename", filename);
//     console.log("blobUrl", blobUrl);
//     const formData = new FormData();
//     formData.append('file', new Blob([blobUrl], { type: 'application/pdf' }), filename); // Ensure content type for PDF

//     try {
//         const response = await axios.post('/api/Annotation/NewVersion', formData, {
//             headers: {
//                 'Content-Type': 'multipart/form-data', // Set request content type
//             },
//         });

//         isUploading.value = false; // Reset uploading flag (optional)
//         console.log('File uploaded successfully!', response.data);
//         // Handle successful API response (e.g., notify iframe)
//     } catch (error) {
//         isUploading.value = false; // Reset uploading flag (optional)
//         console.error('Error uploading file:', error);
//         // Handle API call errors
//     }
// };

// onMounted(() => {
//     window.addEventListener('message', handleIframeMessage);
// });

// Expose isUploading for potential UI updates (optional)
// const url = ref(`https://localhost:7278/api/Document/pdf/${DocumentDetails.value?.files[0]?.id}`);
// const op = ref();
// const members = ref([
//     {
//         name: "Amy Elsner",
//         image: "amyelsner.png",
//         email: "amy@email.com",
//         role: "Owner",
//     },
//     {
//         name: "Bernardo Dominic",
//         image: "bernardodominic.png",
//         email: "bernardo@email.com",
//         role: "Editor",
//     },
//     {
//         name: "Ioni Bowcher",
//         image: "ionibowcher.png",
//         email: "ioni@email.com",
//         role: "Viewer",
//     },
// ]);
onMounted(fetchUsernames);

</script>

<style lang="scss" scoped>
.details {
  max-width: 400px;
  padding: 20px;
  background-color: #f5f5f5;
  border-radius: 10px;
}



@media (max-width: 768px) {
  .row {
    flex-wrap: wrap;
    /* Wrap info on smaller screens */
  }

  .col {
    flex: 1 0 50%;
    /* Allow details to take up to 50% width */
  }
}



.row {
  margin-bottom: 1.5rem;
}

.col-sm-2,
.col-sm-5 {
  font-weight: bold;
}

.share-section,
.invite-section,
.team-members-section {
  margin-bottom: 1.5rem;
}

.input-group-append button {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  margin-right: 1rem;
}




.document-files-container {
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 10px;
  margin-bottom: 20px;
}

.document-files-title {
  display: flex;
  align-items: center;
  font-weight: bold;
  margin-bottom: 5px;
}

.document-files-title .material-icons {
  margin-right: 5px;
  color: #666;
  font-size: 18px;
}

.document-files-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.document-files-list li {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}

.file-icon {
  margin-right: 10px;
  color: #999;
  font-size: 16px;
}

.file-name {
  font-size: 14px;
}

.autocomplete-dropdown {
  position: absolute;
  background-color: white;
  border: 1px solid #ccc;
  max-height: 150px;
  overflow-y: auto;
}

.autocomplete-dropdown div {
  padding: 5px;
  cursor: pointer;
}

.smaller-input {
  width: 300px;
}
</style>
