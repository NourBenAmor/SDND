<template>
  <div v-if="show" class="modal-card">
    <p>{{ message }}</p>
    <div class="button-container">
      <button @click="confirm">
        <i class="fas fa-check" beat></i>
      </button>
      <button @click="cancel">
        <i class="fas fa-times"></i>
      </button>
    </div>
  </div>
</template>

<script setup>

const { show, message } = defineProps({
  show: Boolean,
  message: {
    type: String,
    default: "Are you sure ?",
  },
});

const emit = defineEmits(["confirm", "cancel"]);

const confirm = () => {
  emit("confirm");
};

const cancel = () => {
  emit("cancel");
};
</script>

<style scoped>
/* Include Font Awesome CSS for icons */
@import url("https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css");

.modal {}

.modal-card {
  position: fixed;
  top: 50%;
  left: 50%;
  background-color: #fff;
  /* White background */
  padding: 25px;
  border-radius: 8px;
  /* Rounded corners */
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
  /* Subtle drop shadow */
  width: 350px;
  /* Modal width */
  font-size: large;
  transform: translate(-50%, -50%);
  /* Semi-transparent overlay */
  /* display: flex; */
  z-index: 10001;
  /* justify-content: center;
  align-items: center; */
}

.button-container {
  display: flex;
  justify-content: space-between;
  margin-top: 15px;
  margin-right: 15px;
}

button {
  padding: 0px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  background-color: transparent;
  /* Transparent background for icons */
  color: #333;
  /* Dark gray text color */
  /* Increase icon size */
  transition: all 0.2s ease-in-out;
  /* Smooth hover effect */
}

.fas {
  font-size: 27px;
}

button:hover {
  color: #ff0000;
  /* Blue on hover */
}

/* Optional: Add subtle hover animations for a more dynamic feel */
/* You can explore CSS animations for hover effects like pulse or scale */
</style>
