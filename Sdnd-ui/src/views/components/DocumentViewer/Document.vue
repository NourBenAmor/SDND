<template>
    <Splitter style="height: 85vh" class="m-0">
        <SplitterPanel class="flex align-items-center justify-content-center overflow-auto">
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
                                    <div class="text-xl font-bold">Document Files</div>
                                </template>
                                <Column v-for="col of FileColumns" :key="col.field" :field="col.field"
                                    :header="col.header">
                                </Column>
                                <Column :key="123456"></Column>
                                <template #footer>
                                    <div class="flex justify-content-start">
                                        <Button icon="fas fa-plus" label="Add" severity="success" />
                                    </div>
                                </template>
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
            <div class="m-5" v-if="activeitem == 4">

            </div>
        </SplitterPanel>
        <SplitterPanel class="flex align-items-center justify-content-center">


            <FileView />

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
//const router = useRouter();
//const route = useRoute();


const src = ref('')
src.value = encodeURIComponent("https://localhost:7278/api/document/pdf/e7171698-1f32-465a-b632-7223c0e09cc0");
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

const FileColumns = [
    { field: 'name', header: 'Name' },
    { field: 'formattedFileSize', header: 'Size' },
    { field: 'filePath', header: 'Path' }
];
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

</script>

<style lang="scss" scoped>
.details {
    max-width: 400px;
    padding: 20px;
    background-color: #f5f5f5;
    border-radius: 10px;
}

.document-info {
    font-size: 16px;
    margin-bottom: 10px;
}

.overlay-panel {
    max-width: 30rem;
}

.overlay-content {
    padding: 1.5rem;
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

.overlay-content h4 {
    margin-top: 0;
}

.row {
    margin-bottom: 2rem;
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
</style>
