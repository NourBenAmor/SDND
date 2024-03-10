<template>
  <div class="document-view-container">
    <div class="pdf-container">
      <pdf-annotate :file="documentUrl" v-if="documentUrl"></pdf-annotate>
      <div v-else>Loading...</div>
    </div>
    <button class="share-btn" @click="shareDocument">
      <i class="fas fa-share"></i>
      <span class="share-text">Share Document</span>
    </button>

  </div>
</template>

<script setup>
import { ref } from 'vue';

const documentUrl = ref(null);

const shareDocument = () => {
  console.log('Document shared!');
};



</script>

<style scoped>
.document-view-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
  background-color: #fff;
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
  width: 80%;
  height: 600px;
  margin: auto;
}

.pdf-container {
  flex: 1;
  margin-bottom: 20px;
}

.share-btn {
  background: none;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
}

.share-btn:hover {
  animation: pulse 0.5s infinite alternate;
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  100% {
    transform: scale(1.1);
  }
}

.share-btn .fas {
  font-size: 24px;
  color: #007bff;
  margin-right: 5px;
}

.share-text {
  font-size: 16px;
  color: #007bff;
}
</style>

