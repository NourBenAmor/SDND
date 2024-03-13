<script setup>
  import { ref } from 'vue';
import pdf from 'pdfvuer';
const src = ref('http://localhost:7278/api/document/pdf/8304771c-8250-4adb-9491-d6776e006ece');


</script>
<template>
  <main>
      <pdf
        class="viewer"
        :src="src"
        :page="1"
        >
        <slot>
          loading content here...
        </slot>
          
      </pdf>
  </main>
</template>
<style scoped>
  html, body {
    margin: 0;
    padding: 0;
  }
  .viewer {
    height: 100vh;
    margin: 20px auto;
    width: 120dvh;
  }
</style>