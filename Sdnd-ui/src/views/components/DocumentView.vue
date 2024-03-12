<script setup>
import * as pdfjsLib from 'pdfjs-dist/build/pdf';
import {ref , onMounted } from 'vue';

    // Reference to the canvas element
    const canvasRef = ref(null);

    // Function to load and render a PDF
    const loadPdf = async (pdfUrl = "../pdfViewer/scout.pdf") => {
      const pdfDoc = await pdfjsLib.getDocument(pdfUrl);
      const firstPage = await pdfDoc.getPage(1);
      const viewport = firstPage.getViewport({ scale: 1 });
      const context = canvasRef.value.getContext('2d');

      canvasRef.value.height = viewport.height;
      canvasRef.value.width = viewport.width;

      await firstPage.render({ canvasContext: context, viewport });
    };
    onMounted(loadPdf);
defineProps({
  documentUrl: {
    type: String,
    required: true,
  },
});

// Method to handle annotation updates

</script>
<template>
  <div class="document-view-container">
    <canvas id="the-canvas" ref="canvasRef" style="border: 1px solid black; direction: ltr;"></canvas>

    
  </div>
</template>


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




