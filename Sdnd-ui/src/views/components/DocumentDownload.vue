<template>
  <div>
    <input type="file" @change="handleFileChange" />
    <button @click="downloadFile">Télécharger</button>
  </div>
</template>

<script>
export default {
  data() {
    return {
      selectedFile: null,
    };
  },
  methods: {
    handleFileChange(event) {
      this.selectedFile = event.target.files[0];
    },
    downloadFile() {
      if (this.selectedFile) {
        const formData = new FormData();
        formData.append("file", this.selectedFile);
        axios
          .post("https://localhost:3000/api/download", formData, {
            responseType: "blob",
          })
          .then((response) => {
            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement("a");
            link.href = url;
            link.setAttribute("download", this.selectedFile.name);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
          })
          .catch((error) => {
            console.error("Erreur lors du téléchargement du fichier:", error);
            alert("Une erreur est survenue lors du téléchargement du fichier.");
          });
      } else {
        alert("Veuillez sélectionner un fichier à télécharger.");
      }
    },
  },
};
</script>
