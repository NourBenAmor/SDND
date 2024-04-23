<template>
  <div>
    <h2>Historique des Annotations pour {{ document.title }}</h2>
    <ul>
      <li v-for="annotation in annotations" :key="annotation.id">
        <div>{{ annotation.annotationDate }}</div>
        <div>{{ annotation.content }}</div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: ["document"],
  data() {
    return {
      annotations: [],
    };
  },
  mounted() {
    this.fetchannotations();
  },
  methods: {
    async fetchannotations() {
      const response = await fetch(
        `/api/documents/${this.document.id}/annotations`,
      );
      this.annotations = await response.json();
    },
  },
};
</script>
