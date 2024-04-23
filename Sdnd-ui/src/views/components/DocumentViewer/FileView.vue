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
        <button type="button" class="btn btn-link text-secondary px-1 mb-0 mx-2" data-bs-toggle="modal"
          data-bs-target="#exampleModalMessage">
          <i class="fas fa-share text-primary me-1" aria-hidden="true"></i>Share
        </button>
        <button @click="addAnnotation" class="btn btn-link text-secondary px-1 mb-0 mx-2">
          <i class="fas fa-pen text-primary me-1" aria-hidden="true"></i>
          <a style="text-decoration: none; color: inherit" :href="viewersrc" target="_blank">Add Annotations</a>
        </button>
      </div>
    </div>

    <div class="file-container">

      <div v-for="page in pages" :key="page">
        <VuePDF :pdf="pdf" :scale="scale" :page="page" style="margin-bottom: 10px" :fit-parent="fitParent">
          <div>Loading...</div>
        </VuePDF>
      </div>
    </div>

    <!-- Modal -->
    <div class="modal fade dark" id="exampleModalMessage" tabindex="-1" role="dialog"
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
              <!-- <div class="form-group">
                <label for="message-text" class="col-form-label">Message:</label>
                <textarea class="form-control" id="message-text"></textarea>
              </div> -->
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
    </div>
  </main>
</template>

<script setup>
import { ref } from "vue";
import BaseApiService from "../../../services/apiService";
import { useRouter, useRoute } from "vue-router";
import { VuePDF, usePDF } from "@tato30/vue-pdf";

// const showModal = ref(false);
const router = useRouter();
const route = useRoute();
const username = ref("");
const documentId = ref(route.params.id);
//const src = defineProps("url");
const src =
  "https://localhost:7278/api/document/pdf/49c621f7-9749-46df-b419-aae1d45ce60c";
const viewersrc = ref("../../../web/viewer.html?file=" + src.value);
const scale = ref(1);
const fitParent = ref(false);
const { pdf, pages } = usePDF(src);
const SignatureToolbar = ref(false);
//   const showShareModal = (index) => {
//     showModal.value = true;

//   };

const sharedocument = async () => {
  try {
    const ShareRequest = {
      username: username.value,
      documentId: documentId.value,
    };
    console.log(ShareRequest);
    const response =
      await BaseApiService(`Document/Share`).create(ShareRequest);
    console.log(response.data);
    router.push("/shared-documents");
  } catch (e) {
    console.error(e);
  }
};
const showSignatureToolbar = () => {
  SignatureToolbar.value = !SignatureToolbar.value;
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
</script>

<style scoped>
.container {
  width: fit-content;
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
  flex-direction: column;
  justify-content: start;
  align-items: center;
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
