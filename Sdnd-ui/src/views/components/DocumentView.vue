<template>
  <div class="document-view-container">
    <pdf-annotate
      :file="documentUrl"
      v-if="documentUrl"
      @update-annotations="handleAnnotationUpdate"
    ></pdf-annotate>
    <div v-else>Loading...</div>
  </div>
</template>

<script>
import PdfAnnotate from 'pdf-annotate';
export default {
  components: {
    PdfAnnotate
  },
  props: {
    documentUrl: {
      type: String,
      required: true
    }
  },
  methods: {
    handleAnnotationUpdate(annotations) {
      console.log('Updated annotations:', annotations);
      // Add your custom logic here to handle the updated annotations
    }
  }
}
</script>

<style scoped>
.document-view-container {
  padding: 20%;
  background-color: #fff;
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
  width: 70%;
  margin: auto;
}
</style>
