<template>
  <main class="container">
    <div class="button-container">
      <button @click="downloadDocument" class="btn btn-link text-primary px-3 mb-0">
        <i class="fas fa-download text-primary me-2" aria-hidden="true"></i>Download
      </button>
      <button type="button" class="btn btn-link text-primary px-3 mb-0" data-bs-toggle="modal"
        data-bs-target="#exampleModalMessage">
        <i class="fas fa-share text-primary me-2" aria-hidden="true"></i>Share
      </button>
      <button  class="btn btn-link text-primary px-3 mb-0">
        <i class="fas fa-pen text-primary me-2" aria-hidden="true"></i>Add Annotations
      </button>
      <!-- <button @onclick="sharedocument" class="btn btn-link text-primary px-3 mb-0">
        <i class="fas fa-share text-primary me-2" aria-hidden="true"></i>Share
      </button> -->
    </div>
    <pdf class="viewer" :src="src" :page="1">
      <slot>
        loading content here...
      </slot>
    </pdf>

    <!-- Modal -->
    <div class="modal fade" id="exampleModalMessage" tabindex="-1" role="dialog"
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
                <input type="text" class="form-control" placeholder="Write a valid Username" id="recipient-name"
                  v-model="username">
              </div>
              <!-- <div class="form-group">
                <label for="message-text" class="col-form-label">Message:</label>
                <textarea class="form-control" id="message-text"></textarea>
              </div> -->
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">Close</button>
            <button @click="sharedocument" type="button" class="btn bg-gradient-primary">Share</button>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup>
  import { ref } from 'vue';
  import pdf from 'pdfvuer';
  import BaseApiService from '../../services/apiService';
  import { useRouter,useRoute } from 'vue-router';
  // const showModal = ref(false);
  const router = useRouter();
  const route = useRoute();
  const username =  ref('');
  const documentId = ref(route.params.id);
  const src = ref(`http://localhost:7278/api/Document/pdf/${documentId.value}`);

  

  
//   const showShareModal = (index) => {
//     showModal.value = true;
    
//   };
  const sharedocument = async ()=>{
    try {

      const ShareRequest = {
        username : username.value,
        documentId : documentId.value

      }
      console.log(ShareRequest);
      const response = await BaseApiService(`Document/Share`).create(ShareRequest);
      console.log(response.data);
      router.push('/shared-documents');
    }
    catch(e){
      console.error(e);
    }
  }

//   const downloadDocument = async () => {
  
// }

</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  align-items: center; 
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
</style>