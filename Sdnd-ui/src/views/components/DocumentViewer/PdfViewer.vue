<script setup>
import VuePdfEmbed from 'vue-pdf-embed'

// essential styles
import 'vue-pdf-embed/dist/style/index.css'

// optional styles
import 'vue-pdf-embed/dist/style/annotationLayer.css'
import 'vue-pdf-embed/dist/style/textLayer.css'
const url = defineProps({
    url: String
})

</script>

<template>
    <VuePdfEmbed annotation-layer text-layer :source="url" />
</template>