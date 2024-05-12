<template>
  <main class="container">
    <div class="tool-bar">
      <span class="page-info">
        Page <span id="page-num"></span> of <span id="page-count"></span>
      </span>
      <div class="middle-bar">
        <div class="text-Primary">{{ scale * 100 }} %</div>
        <button @click="scale = scale < 2 ? scale + 0.25 : scale" class="btn btn-link text-primary px-2 mb-0 mx-2">
          <i class="fa-solid fa-magnifying-glass-plus"></i>
        </button>
        <button @click="scale = scale > 0.25 ? scale - 0.25 : scale" class="btn btn-link text-primary px-2 mb-0 mx-2">
          <i class="fa-solid fa-magnifying-glass-minus"></i>
        </button>
        <button @click="scale = 1.88" class="btn btn-link text-primary px-2 mb-0 mx-2">
          <i class="fa-solid fa-expand"></i>
        </button>
        <button @click="scale = 1" class="btn btn-link text-primary px-2 mb-0 mx-2">
          <i class="fa-solid fa-compress"></i>
        </button>
      </div>

      <div>
        <button @click="downloadDocument" class="btn btn-link text-secondary px-1 mb-0 mx-2">
          <i class="fas fa-download text-primary me-1" aria-hidden="true"></i>Download
        </button>
        <button @click="addAnnotation" class="btn btn-link text-secondary px-1 mb-0 mx-2">
          <i class="fas fa-pen text-primary me-1" aria-hidden="true"></i>
          <a style="text-decoration: none; color: inherit" arget="_blank">Add Annotations</a>
        </button>
      </div>
    </div>
    <div class="file-container">
      <Loading v-model:active="savingAnnotations" />
      <div v-if="!pdfSources">
        <h1> No available Pdfs </h1>
      </div>
      <div v-else v-for="page in pages" :key="page">
        <div style="position:relative">
          <button class="toggleButton" @click="toggleSignature">
            <svg width="20px" height="20px" viewBox="0 0 1920 1920" xmlns="http://www.w3.org/2000/svg">
              <g fill="#888888" fill-rule="evenodd" clip-rule="evenodd" stroke="none" stroke-width="1">
                <path
                  d="M1468.235 113v91.142L822.674 862.89a87.85 87.85 0 0 0-24.598 61.495l-.002 429.859c-.24.366-.477.736-.71 1.109-23.717 42.918-79.058 105.035-112.94 101.647-33.883-3.388-44.048-27.106-72.283-96-36.141-89.224-94.87-206.682-190.87-197.647-120.847 10.165-179.577 225.882-199.906 320.753-6.55 31.188 13.424 61.78 44.611 68.33 31.188 6.549 61.78-13.425 68.33-44.612a484.518 484.518 0 0 1 97.13-225.883s30.493 10.165 77.929 127.624c47.435 117.459 99.388 161.506 169.411 166.023h9.036c112.94 0 196.517-143.435 205.553-160.376 10.037-16.097 10.996-35.285 4.266-51.575h339.697a87.85 87.85 0 0 0 61.496-26.355l169.411-172.872v642.708H0V113h1468.235Zm-903.53 564.706H225.883v112.941h338.824V677.706Zm225.883-225.882H225.882v112.94h564.706v-112.94Z" />
                <path
                  d="m1903.059 468.765-225.883-225.883a56.47 56.47 0 0 0-80.188 0L919.341 920.53a56.476 56.476 0 0 0-15.813 39.53v282.353h282.354a56.47 56.47 0 0 0 39.53-16.941l677.647-677.647c21.523-21.959 21.523-57.101 0-79.06Zm-208.941 128.753-145.694-145.694 89.223-89.224 145.694 145.694-89.223 89.224Z" />
              </g>
            </svg>
          </button>
          <VuePDF :pdf="pdf" :scale="scale" :page="page" style="margin-bottom: 10px" :fit-parent="fitParent">
            <div class="spinner-grow m-0 9-0" style="width:100%; height:100%;" role="status">
              <span class="sr-only m-0 p-0">Loading...</span>
            </div>
          </VuePDF>
          <Signaturepdf @save-annotation="onSaveAnnotation" :source="src" :page="page" v-if="showSignature"
            style="position:absolute;left: 0; top: 0;  width: 100%; height: 100%;" />
        </div>
      </div>
    </div>

    <!-- share a document modal -->
    <!-- <div class="modal fade dark" id="exampleModalMessage" tabindex="-1" role="dialog"
      aria-labelledby="exampleModalMessageTitle" aria-hidden="true" data-bs-backdrop="false">
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">
              Share This Document
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">×</span>
            </button>
          </div>
          <div class="modal-body">
            <form>
              <div class="form-group">
                <label for="recipient-name" class="col-form-label">Share With</label>
                <input type="text" class="form-control" placeholder="Write a valid Username" id="recipient-name"
                  v-model="username" />
              </div>
              <div class="form-group">
                <label for="message-text" class="col-form-label">Message:</label>
                <textarea class="form-control" id="message-text"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">
              Close
            </button>
            <button @click="sharedocument" type="button" class="btn bg-gradient-primary">
              Share
            </button>
          </div>
        </div>
      </div>
    </div> -->
  </main>
</template>

<script setup>
import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/css/index.css';
import Signaturepdf from "./Signaturepdf.vue";
import { ref, computed, onMounted } from "vue";
import BaseApiService from "../../../services/apiService";
import { useStore } from "vuex";
import { VuePDF, usePDF } from "@tato30/vue-pdf";
// const showModal = ref(false);
const store = useStore();
const props = defineProps({
  pdfSources: Array,
  selected: Number
});
const documentId = computed(() => store.state.documentId);
const savingAnnotations = ref(false);
const src = ref('');
const { pdf, pages } = usePDF(src);
import { watch } from 'vue';
onMounted(() => {
  console.log('fichier', props.selected);
  if (props.pdfSources && props.pdfSources.length > 0) {
    const selectedSource = props.pdfSources[props.selected];
    if (selectedSource) {
      src.value = `https://localhost:7278/api/document/pdf/${selectedSource}`;
      console.log(src.value);

    }
    else {
      // Handle the case when props.selected is an invalid index
      console.log('Invalid index:', props.selected);
    }
    savingAnnotations.value = false;
  }
  else {
    // Handle the case when props.pdfSources is an empty array
    console.log('No PDF sources provided');
  }
});
watch(() => props.selected, (newValue) => {
  console.log('fichier', newValue);
  if (props.pdfSources && props.pdfSources.length > 0) {
    const selectedSource = props.pdfSources[newValue];
    if (selectedSource) {
      src.value = `https://localhost:7278/api/document/pdf/${selectedSource}`;
      console.log(src.value);

    }
    else {
      // Handle the case when props.selected is an invalid index
      console.log('Invalid index:', props.selected);
    }
  }
  else {
    // Handle the case when props.pdfSources is an empty array
    console.log('No PDF sources provided');
  }
  savingAnnotations.value = false;

});
const scale = ref(1);
const fitParent = ref(false);
const onSaveAnnotation = (fileId) => {
  savingAnnotations.value = true;
  src.value = `https://localhost:7278/api/document/pdf/${fileId}`;
  setTimeout(() => {
    savingAnnotations.value = false;
  }, 2000);
};
// const SignatureToolbar = ref(false);
//   const showShareModal = (index) => {
//     showModal.value = true;

//   };
// const sharedocument = async () => {
//   try {
//     const ShareRequest = {
//       username: username.value,
//       documentId: documentId.value,
//     };
//     console.log(ShareRequest);
//     const response =
//       await BaseApiService(`Document/Share`).create(ShareRequest);
//     console.log(response.data);
//     router.push("/shared-documents");
//   } catch (e) {
//     console.error(e);
//   }
// };
// const showSignatureToolbar = () => {
//   SignatureToolbar.value = !SignatureToolbar.value;
// }; -->
const addAnnotation = () => {
  // Encode the URL to ensure proper handling of special characters
  const encodedUrl = encodeURIComponent(src.value);
  console.log(encodedUrl);
  window.location.href = `http://127.0.0.1:5500/web/viewer.html?file=${encodedUrl}`;
};



const downloadDocument = async () => {
  try {
    const response = await BaseApiService("Document/Download").get(
      documentId.value,
      {
        responseType: "blob",
      },
    );
    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", "document.pdf");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (error) {
    console.error("Error downloading document:", error);
  }
};

const showSignature = ref(false);
const toggleSignature = () => {
  showSignature.value = !showSignature.value;
};
</script>

<style scoped>
.container {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  margin: 0px;
  padding: 0px 0px 0px 0px;
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
  background: #f9f9fb;
  backdrop-filter: 1px;
  box-shadow: 1 1 0 #d4d4d7;
  color: #585858;
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
  background: #d4d4d7;
  color: #fff;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: start;
  align-items: center;
  overflow: auto;
  height: 100%;
}



.file-container::-webkit-scrollbar {
  background-color: #f9f9fa;
}

.file-container::-webkit-scrollbar-thumb {
  background-color: #d4d4d498;
  border-left: 1px solid #f9f9fa;
  border-right: 1px solid #f9f9fa;
}

.toggleButton {
  background: #f9f9fb00;
  color: #585858;
  padding: 0px;
  width: auto;
  cursor: pointer;
  border: none;
  position: absolute;
  top: 8px;
  left: 8px;
  z-index: 100;
}
</style>
