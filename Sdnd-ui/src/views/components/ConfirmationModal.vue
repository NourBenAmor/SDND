<template>
  <div v-if="show" class="modal">
    <div class="modal-content">
      <p>{{ message }}</p>
      <div class="button-container">
        <button @click="confirm">Yes</button>
        <button @click="cancel">No</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const { show, message } = defineProps({
  show: Boolean,
  message: {
    type: String,
    default: 'Are you sure?'
  }
});

const emit = defineEmits(['confirm', 'cancel']);

const confirm = () => {
  emit('confirm');
};

const cancel = () => {
  emit('cancel');
};
</script>


<style scoped>
.modal {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background-color: white;
  width: 300px; 
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.5);
}

.button-container {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
}

button {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

button:first-child {
  background-color: green;
  color: white;
}

button:last-child {
  background-color: red;
  color: white;
}
</style>
