<template>
  <Splitter style="height: 90vh" class="m-0 overflow-none">
    <SplitterPanel class="flex align-items-center justify-content-center splitter">
      <div class="d-flex justify-content-between">
        <TabMenu :model="items"> </TabMenu>
      </div>
      <div class="overflow-auto" v-if="activeitem == 0">
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
            <div class="col-12 col-sm-10">{{ documentDetails?.name }}</div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Description</div>
            <div class="col-12 col-sm-10">
              {{ documentDetails?.description }}
            </div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Status</div>
            <div class="col-12 col-sm-10">
              <argon-badge variant="gradient" color="success">
                {{ getDocumentStateString(documentDetails?.documentState) }}
              </argon-badge>
            </div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Created at</div>
            <div class="col-12 col-sm-10">
              <argon-badge variant="gradient" color="success">
                {{ formatDate(documentDetails?.addedDate) }}
              </argon-badge>
            </div>
          </div>
          <div class="row">
            <div class="col-12 col-sm-2">Last Modified at</div>
            <div class="col-12 col-sm-10">
              <argon-badge variant="gradient" color="success">
                {{ formatDate(documentDetails?.updatedDate) }}
              </argon-badge>
            </div>
          </div>
          <div class="row">
            <div class="document-files-container card">
              <DataTable v-model:selection="selectedPdf" selection-mode="single" :value="documentDetails?.files">
                <template #header>
                  <div class="d-flex align-items-center justify-content-between">
                    <h6 class="text-xl font-bold p-0 m-0">Files</h6>
                  </div>
                </template>
                <Column v-for="col of FileColumns" :key="col.field" :field="col.field" :header="col.header">
                  <template #body="slotProps">
                    <div v-if="col.field === 'actions'" class="d-flex ml-0">
                      <Button icon="fas fa-eye" class="p-button-rounded p-button-text"
                        @click="viewFile(slotProps.data)" />
                    </div>
                    <div v-if="col.field == 'addedDate'">
                      {{ advancedformatdate(slotProps.data.addedDate) }}
                    </div>

                    <div v-else>
                      {{ slotProps.data[col.field] }}
                    </div>
                  </template>
                </Column>
                <template #empty>
                  <div class="d-flex justify-content-center py-5 bg-light">
                    <h4 class="p-text-secondary font-weight-light fs-5">
                      No Files found for this document.
                    </h4>
                  </div>
                </template>
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
      <div class="overflow-auto" v-if="activeitem == 1">
        <DocumentEdit :docDetails="documentDetails" @refresh-documentdetails="UpdatedRefetch"
          @addfile-emit="handleEmit" />
      </div>
      <div class="m-5 overflow-auto" v-if="activeitem == 2">
        <DocumentHistory />
      </div>
      <div class="comment-section mx-5" v-if="activeitem === 3">
        <CommentsComponent />
      </div>
      <div class="m-5" v-show="activeitem === 4">
        <CollaborationWindow />
      </div>
    </SplitterPanel>
    <SplitterPanel v-if="selectedPdf" v-show="IsOpen"
      class="flex align-items-center justify-content-center overflow-none" style="width: 70%;">
      <FileView @close-button="close" :selected="activePdf || 0" :pdfSources="pdfSources" />
    </SplitterPanel>
  </Splitter>
</template>

<script setup>
//import VuePdfjs from './VuePdfjs.vue';
import FileView from "./FileView.vue";
//import PdfViewer from "./PdfViewer.vue";
import CollaborationWindow from "./CollaborationWindow.vue";
import CommentsComponent from "./CommentsComponent.vue";
import DataTable from "primevue/datatable";
import Column from "primevue/column";
import Button from "primevue/button";
import DocumentHistory from "./DocumentHistory.vue";
import DocumentEdit from "../DocumentEdit.vue";
import Skeleton from "primevue/skeleton";
import ArgonBadge from "@/components/ArgonBadge.vue";
import Splitter from "primevue/splitter";
import SplitterPanel from "primevue/splitterpanel";
import { ref, computed, watch } from "vue";
import TabMenu from "primevue/tabmenu";
import BaseApiService from "../../../services/apiService";
import { onMounted } from "vue";
import { useStore } from "vuex";
//const router = useRouter();
//const route = useRoute();
// const fileId = ref('e7171698-1f32-465a-b632-7223c0e09cc0');
//const src = ref(`https://localhost:7278/api/document/pdf/${fileId.value}`);

//const url = ref('');
//url.value = `"/web/viewer.hile${src.value}"`;
//const src = ref("https://localhost:7278/api/document/pdf/49c621f7-9749-46df-b419-aae1d45ce60c");
const store = useStore();
const documentId = computed(() => store.state.documentId);
const isFetched = ref("false");
const selectedPdf = ref(null);
const emits = defineEmits(["refresh-documents", "addfile-emit"]);
const activePdf = ref(null);
const pdfSources = ref([]);
const IsOpen = ref(false);
const documentDetails = ref(null);
// const props = defineProps({
//     documentId: String // Enforce string type for clarity and potential validation
// });

const close = () => {
  IsOpen.value = false;
}
const handleEmit = (payload) => {
  emits("addfile-emit", payload);
}
watch(() => selectedPdf.value, (newValue) => {
  console.log('selectedPdf changed to ', newValue);
  activePdf.value = pdfSources.value.indexOf(newValue.id);
  IsOpen.value = true;
});
onMounted(async () => {
  isFetched.value = false;
  await fetchdocumentDetails(documentId.value);
  if (documentDetails.value && documentDetails.value.files && documentDetails?.value?.files?.length > 0) {
    pdfSources.value = documentDetails.value.files.map((file) => file.id);
    activePdf.value = pdfSources.value.indexOf(documentDetails.value.files[0].id);
  }
});
const UpdatedRefetch = async () => {
  await fetchdocumentDetails(documentId.value);
  emits("refresh-documents");
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

const formatDate = (dateString) => {
  const date = new Date(dateString);
  const options = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long', hour: 'numeric', minute: 'numeric' };
  return date.toLocaleDateString(undefined, options);
};
const advancedformatdate = (dateString) => {
  const date = new Date(dateString);
  const now = new Date();
  const diff = now - date;
  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 1) {
    return `${days} days ago`;
  } else if (hours > 1) {
    return `${hours} hours ago`;
  } else if (minutes > 1) {
    return `${minutes} minutes ago`;
  } else {
    return `${seconds} seconds ago`;
  }
};
const fetchdocumentDetails = async (id) => {
  try {
    if (id == null) {
      return;
    }

    const response = await BaseApiService(`Document/${id}`).list();
    documentDetails.value = response.data;
    isFetched.value = true;
  } catch (error) {
    isFetched.value = false;
    console.error("Error fetching document:", error);
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
  // {
  //   label: "History",
  //   icon: "fas fa-history",
  //   command: () => {
  //     activeitem.value = 2;
  //   },
  // },
  {
    label: "Comments",
    icon: "fa-solid fa-comments",
    command: () => {
      activeitem.value = 3;
    },
  },
  {
    label: "Collaboration",
    icon: "fa-solid fa-user-group",
    command: () => {
      activeitem.value = 4;
    },
  },
]);



const FileColumns = [
  { field: "name", header: "Name" },
  { field: "formattedFileSize", header: "Size" },
  { field: "id", header: "Id" },
  { field: "addedDate", header: "Added Date" },
  { field: "actions", header: "Actions" },
];



//const isDocumentAuthor = ref(true);
const viewFile = (data) => {

  console.log(data);
  // Implement file viewing logic here
  IsOpen.value = true
  selectedPdf.value = data.id;
};


// const revokeAccess = async (userId) => {
//   try {
//     await axios.post('/api/revoke-access', {
//       userId,
//       documentId: currentDocument.id,
//     });

//     // After the API call is successful, remove the user from the local sharedUsers array
//     sharedUsers.value = sharedUsers.value.filter(user => user.id !== userId);
//   } catch (error) {
//     console.error('Error revoking access:', error);
//   }
// };
// toggleDropdown(userId) {
//   this.dropdownUserId = this.dropdownUserId === userId ? null : userId;
// }
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

.overflow-auto {
  overflow: auto;
  height: 90%;
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

.splitter::-webkit-scrollbar {
  background-color: #f9f9fa;
}

.splitter::-webkit-scrollbar-thumb {
  background-color: #d4d4d498;
  border-left: 1px solid #f9f9fa;
  border-right: 1px solid #f9f9fa;
}

.splitter {
  margin-right: 5px;
}

.form-group {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  margin-right: 10px;
}

.form-group label {
  font-size: 14px;
  color: #666;
  margin-bottom: 5px;
}

.form-group input {
  padding: 5px;
  border: 1px solid #ccc;
  border-radius: 5px;
}

.comment-section {
  height: 90%;
}

.comment-section,
.share-section {
  background-color: #f3f6f8;
  padding: 20px;
  border-radius: 10px;
  margin-bottom: 20px;

}
</style>
