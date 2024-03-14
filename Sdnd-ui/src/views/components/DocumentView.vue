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

<script setup>
  import { ref } from 'vue';
  import pdf from 'pdfvuer';
  import { useRoute } from 'vue-router';

  const route = useRoute();
  const documentId = ref(route.params.id);
  const src = ref(`https://localhost:7278/api/Document/pdf/${documentId.value}`);
  console.log(route); // Log the route object to inspect its contents

</script>

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
