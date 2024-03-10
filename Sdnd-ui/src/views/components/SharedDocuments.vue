<template>
  <div class="card">

    <div class="shared-documents-table-container mt-4">
      <div class="card mt-4">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h6 class="mb-0">Shared with Me</h6>
        </div>
        <div class="card-body px-0 pt-0 pb-2">
          <div class="table-responsive p-0">
            <table class="table align-items-center mb-0">
              <thead>
                <tr>
                  <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                    Title
                  </th>
                  <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">
                    Owner
                  </th>
                  <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7"></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(document, index) in sharedDocuments" :key="index">
                  <td>
                    <div class="d-flex px-2 py-1">
                      <div class="d-flex flex-column justify-content-center">
                        <h6 class="mb-0 text-sm">{{ document.title }}</h6>
                      </div>
                    </div>
                  </td>
                  <td>
                    <p class="text-xs font-weight-bold mb-0">{{ document.owner }}</p>
                  </td>
                  <td class="align-middle">
                    <div class="ms-auto text-end">
                      <button @click="openDocumentView(document)" class="btn btn-link text-green px-3 mb-0">
                        <i class="fas fa-eye text-green ms-2" aria-hidden="true"></i>View
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>

import { ref } from 'vue';
import { useRouter } from 'vue-router';

const sharedDocuments = ref([
  {
    title: 'Shared Document 1',
    owner: 'User A'
  },
  {
    title: 'Shared Document 2',
    owner: 'User B'
  }
]);
const router = useRouter();

const openDocumentView = (document) => {
  router.push({ name: 'document-view', params: { documentData: document } });
};
</script>
