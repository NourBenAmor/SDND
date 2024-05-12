<script setup>
const emit = defineEmits(["update:modelValue"]);

defineProps({
  id: {
    type: String,
    required: true,
  },
  placeholder: {
    type: String,
    default: "",
  },
  rows: {
    type: Number,
    default: 5,
  },
  modelValue: {
    type: String,
    default: "",
  },
});
</script>
<template>
  <div class="form-group">
    <label :for="id" style="display: none;">
      <slot />
    </label>
    <textarea :id="id" class="form-control" :rows="rows" :value="modelValue" :placeholder="placeholder"
      @input="emit('update:modelValue', $event.target.value)"></textarea>
  </div>
</template>
