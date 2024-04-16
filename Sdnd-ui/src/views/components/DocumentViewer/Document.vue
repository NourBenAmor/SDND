<template>
    <Splitter style="height: 85vh" class="m-0">
        <SplitterPanel class="flex align-items-center justify-content-center">
            <div class="d-flex justify-content-between">
                <TabMenu :model="items" />
                <div>
                    <div class="d-flex">
                        <FileUpload :pt="{ button: 'my-switch-slider' }" class="FileUpload" mode="basic" name="demo[]"
                            url="/api/upload" :maxFileSize="1000000" @upload="onUpload" />
                        <Button class="Button" type="button" icon="pi pi-image" label="Image" @click="toggle" />
                        <OverlayPanel ref="op">
                            <div class="flex flex-column gap-3 w-25rem">
                                <div>
                                    <span class="font-medium text-900 block mb-2">Share this document</span>
                                    <InputGroup>
                                        <InputText value="https://primevue.org/12323ff26t2g243g423g234gg52hy25XADXAG3"
                                            readonly class="w-25rem"></InputText>
                                        <InputGroupAddon>
                                            <i class="pi pi-copy"></i>
                                        </InputGroupAddon>
                                    </InputGroup>
                                </div>
                                <div>
                                    <span class="font-medium text-900 block mb-2">Invite Member</span>
                                    <InputGroup>
                                        <Chips disabled></Chips>
                                        <Button label="Invite" icon="pi pi-users"></Button>
                                    </InputGroup>
                                </div>
                                <div>
                                    <span class="font-medium text-900 block mb-2">Team Members</span>
                                    <ul class="list-none p-0 m-0 flex flex-column gap-3">
                                        <li v-for="member in members" :key="member.name"
                                            class="flex align-items-center gap-2">
                                            <img :src="`https://primefaces.org/cdn/primevue/images/avatar/${member.image}`"
                                                style="width: 32px" />
                                            <div>
                                                <span class="font-medium">{{ member.name }}</span>
                                                <div class="text-sm text-color-secondary">{{ member.email }}</div>
                                            </div>
                                            <div
                                                class="flex align-items-center gap-2 text-color-secondary ml-auto text-sm">
                                                <span>{{ member.role }}</span>
                                                <i class="pi pi-angle-down"></i>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </OverlayPanel>
                    </div>

                </div>
            </div>
            <div v-if="activeitem == 0">
                <div class="m-5" v-if="!isFetched">
                    <Skeleton class="mb-2"></Skeleton>
                    <Skeleton width="10rem" class="mb-2"></Skeleton>
                    <Skeleton width="5rem" class="mb-2"></Skeleton>
                    <Skeleton height="2rem" class="mb-2"></Skeleton>
                    <Skeleton width="10rem" height="4rem"></Skeleton>
                </div>
                <form class="m-5 " v-else>
                    <div class="form-group row">
                        <label for="staticEmail" class="col-sm-2 col-form-label">Title</label>
                        <div class="col-sm-10 mr-1">
                            {{ DocumentDetails?.name }}
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="staticEmail" class="col-sm-2 col-form-label">Description</label>
                        <div class="col-sm-10">
                            {{DocumentDetails?.description}}
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="staticEmail" class="col-sm-2 col-form-label">State
                        </label>
                        <div class="col-sm-10">
                            <argon-badge variant="gradient" color="success">
                                {{ getDocumentStateString(DocumentDetails?.documentState) }}
                            </argon-badge>
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="staticEmail" class="col-sm-2 col-form-label">Created at
                        </label>
                        <div class="col-sm-10">
                            <argon-badge variant="gradient" color="success">
                                {{ formatDate(DocumentDetails?.addedDate)}}
                            </argon-badge>
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="staticEmail" class="col-sm-2 col-form-label">Last Modified at
                        </label>
                        <div class="col-sm-10">
                            <argon-badge variant="gradient" color="success">
                                {{ formatDate(DocumentDetails?.updatedDate) }}
                            </argon-badge>
                        </div>
                    </div>
                    <div v-if="!(DocumentDetails?.documentState == 0)">
                        <div v-for="(file, index) in  DocumentDetails?.files " :key="index">
                            <i class="fa-regular fa-file-lines"></i>{{ file?.name }}
                        </div>
                    </div>
                </form>
            </div>
            <div v-if="activeitem==1">
                <DocumentEdit :document-id="documentId" docuemnt-states:documentStates />
            </div>
            <div class="m-5 " v-if="activeitem ==2">
                <Timeline :value="events">
                    <template #opposite="slotProps">
                        <small class="p-text-secondary">{{ slotProps.item.date }}</small>
                    </template>
                    <template #content="slotProps">
                        {{ slotProps.item.status }}
                    </template>
                </Timeline>
            </div>
        </SplitterPanel>
        <SplitterPanel class=" flex align-items-center justify-content-center">
            <div class="tool-bar">
                <span class="page-info">
                    Page <span id="page-num"></span> of <span id="page-count"></span>
                </span>
                <div class="middle-bar">
                    <div class="text-Primary">{{ scale * 100 }} %</div>
                    <button @click="scale = scale < 2 ? scale + 0.25 : scale"
                        class="btn btn-link text-primary px-2  mb-0 mx-2">
                        <i class="fa-solid fa-magnifying-glass-plus"></i>
                    </button>
                    <button @click="scale = scale > 0.25 ? scale - 0.25 : scale"
                        class="btn btn-link text-primary px-2  mb-0 mx-2">
                        <i class="fa-solid fa-magnifying-glass-minus"></i>
                    </button>
                    <button @click="scale = 1.88" class=" btn btn-link text-primary px-2 mb-0 mx-2">
                        <i class="fa-solid fa-expand"></i>
                    </button>
                    <button @click="scale = 1" class="btn btn-link text-primary px-2  mb-0 mx-2">
                        <i class="fa-solid fa-compress"></i>
                    </button>
                </div>

                <div>
                    <button @click="downloadDocument" class="btn btn-link text-secondary px-1  mb-0 mx-2">
                        <i class="fas fa-download text-primary me-1" aria-hidden="true"></i>Download
                    </button>
                    <button type="button" class="btn btn-link text-secondary px-1  mb-0 mx-2" data-bs-toggle="modal"
                        data-bs-target="#exampleModalMessage">
                        <i class="fas fa-share text-primary me-1" aria-hidden="true"></i>Share
                    </button>
                    <button @click="addAnnotation" class="btn btn-link text-secondary px-1  mb-0 mx-2">
                        <i class="fas fa-pen text-primary me-1" aria-hidden="true"></i> <a
                            style="text-decoration: none; color: inherit;" :href="viewersrc" target="_blank">Add
                            Annotations</a>
                    </button>
                    <button @click="showSignatureToolbar" class="btn btn-link text-secondary px-1  mb-0 mx-2">
                        <i class="fas fa-signature text-primary me-1" aria-hidden="true"></i>Add Signature
                    </button>
                </div>
            </div>

            <div class="file-container">

                <PdfAnnotate v-if="SignatureToolbar" />


                <div v-for="page in pages" :key="page">
                    <VuePDF :pdf="pdf" :scale="scale" :page="page" style=" margin-bottom:10px;" :fit-parent="fitParent">
                        <div>
                            Loading...
                        </div>
                    </VuePDF>
                </div>

            </div>

            <!-- Modal -->
            <div class="modal fade dark" id="exampleModalMessage" tabindex="-1" role="dialog"
                aria-labelledby="exampleModalMessageTitle" aria-hidden="true" data-bs-backdrop="false">
                <div class="modal-dialog modal-dialog-centered" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLabel">Share This Document</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">×</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form>
                                <div class="form-group">
                                    <label for="recipient-name" class="col-form-label">Share With</label>
                                    <input type="text" class="form-control" placeholder="Write a valid Username"
                                        id="recipient-name" v-model="username">
                                </div>
                                <!-- <div class="form-group">
                <label for="message-text" class="col-form-label">Message:</label>
                <textarea class="form-control" id="message-text"></textarea>
              </div> -->
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn bg-gradient-secondary"
                                data-bs-dismiss="modal">Close</button>
                            <button @click="sharedocument" type="button" class="btn bg-gradient-primary">Share</button>
                        </div>
                    </div>
                </div>
            </div>
        </SplitterPanel>
    </Splitter>
</template>

<script setup>
// import FileView from './FileView.vue';

import Timeline from 'primevue/timeline';

import Button from 'primevue/button';
import OverlayPanel from 'primevue/overlaypanel';
import FileUpload from 'primevue/fileupload';
import DocumentEdit from '../DocumentEdit.vue';
import Skeleton from 'primevue/skeleton';
import ArgonBadge from "@/components/ArgonBadge.vue";
import Splitter from 'primevue/splitter';
import SplitterPanel from 'primevue/splitterpanel';
import { ref,computed } from 'vue';
import TabMenu from 'primevue/tabmenu';
import BaseApiService from '../../../services/apiService';
import { onMounted} from 'vue';
import { useStore } from "vuex";
//const router = useRouter();
//const route = useRoute();
const events = ref([
    { status: '', date: '', icon: '', color: '#9C27B0' },
    { status: '', date: '', icon: '', color: '#9C27B0' },
    { status: 'File Added', date: '16/04/2024 16:15', icon: 'fa-solid fa-pencil-in-square', color: '#FF9800' },
    { status: 'Document Created', date: '16/04/2024 10:00', icon: 'fas fa', color: '#607D8B' }
]);
const store = useStore();
const documentId = computed(() => store.state.documentId);
const isFetched = ref('false');
// const props = defineProps({
    //     documentId: String // Enforce string type for clarity and potential validation
    // });
    const DocumentDetails = ref(null);
    onMounted(()=>{
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
        if(id==null){
            return;
        }
        const response = await BaseApiService(`Document/${id}`).list();
        console.log(response.data);
        DocumentDetails.value = response.data;
        isFetched.value=true
    } catch (error) {
        isFetched.value = false
        console.error("Error fetching document:", error);
        
    }
};

const activeitem =ref(0);
const items = ref([
    {
        label: 'Details', icon: 'fa-solid fa-bars',
        command: () => {
            activeitem.value = 0
        } },
    {
        label: 'Edit', icon: 'fa-solid fa-pen-to-square',
        command: () => {
            activeitem.value =1;
        } },
    {
        label: 'History', icon: 'fas fa-history',
        command: () => {
            activeitem.value = 2
        } },
    {
        label: 'Messages', icon: 'fa-solid fa-user-group',
        command: () => {
            activeitem.value = 3
        } }
]);
// const url = ref(`https://localhost:7278/api/Document/pdf/${DocumentDetails.value?.files[0]?.id}`);
;
import { 
    useRouter,
    //  useRoute 
    } from 'vue-router';
import { VuePDF, usePDF } from '@tato30/vue-pdf'
import PdfAnnotate from '../PdfAnnotate.vue';
// const showModal = ref(false);
const router = useRouter();
//const route = useRoute();
const username = ref('');

const src = defineProps("url");
const viewersrc = ref("../../../web/viewer.html?file=" + src.value);
const scale = ref(1);
const fitParent = ref(false);
const { pdf, pages } = usePDF("https://localhost:7278/api/document/pdf/7e19b301-346c-49cc-ab03-ee6008f700f9");
const SignatureToolbar = ref(false);
//   const showShareModal = (index) => {
//     showModal.value = true;

//   };


const sharedocument = async () => {
    try {

        const ShareRequest = {
            username: username.value,
            documentId: documentId.value

        }
        console.log(ShareRequest);
        const response = await BaseApiService(`Document/Share`).create(ShareRequest);
        console.log(response.data);
        router.push('/shared-documents');
    }
    catch (e) {
        console.error(e);
    }
}
const showSignatureToolbar = () => {
    SignatureToolbar.value = !SignatureToolbar.value;
}
const downloadDocument = async () => {
    try {
        const response = await BaseApiService('Document/Download').get(documentId.value, {
            responseType: 'blob'
        });

        const url = window.URL.createObjectURL(new Blob([response.data]));
        const link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', 'document.pdf');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
    }
    catch (error) {
        console.error('Error downloading document:', error);
    }
}

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
.my-switch-slider , .Button {
    margin: 1px;
    font-size: small;
}

.container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: fixed;
    height: 100vh;
}



.button-container {
    display: flex;
    gap: 10px;
}

.viewer {
    height: 80vh;
    width: 80%;
}

.modal-backdrop {
    display: none;
}

.tool-bar {
    background: #474747;
    color: #fff;
    padding: 1rem;
    width: 100%;
    height: 60px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}


.middle-bar {
    display: flex;
    justify-content: center;
    align-items: center;
}

.btn:hover {
    opacity: 0.9;
}

.page-info {
    margin-left: 1rem;
}



.error {
    background: orangered;
    color: #fff;
    padding: 1rem;
}



.file-container {
    background: #00000041;
    color: #fff;
    width: 100%;
    display: flex;
    flex-direction: row;
    justify-content: center;
    overflow: auto;
    height: 100%;

}

.file-container::-webkit-scrollbar {
    background-color: #0000001a;
}

.file-container::-webkit-scrollbar-thumb {
    background-color: #474747;
}
</style>