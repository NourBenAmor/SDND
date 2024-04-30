<template>
    <div v-if="comments.length">
        <div v-for="comment in comments" :key="comment.id" class="comment">
            <div class="comment-header">
                <div class="profile-image"
                    :style="comment.profileImageUrl ? `background-image: url(${comment.profileImageUrl})` : `background-color: #007bff`">
                    <span v-if="!comment.profileImageUrl">{{ comment.username[0].toUpperCase() }}</span>
                </div>
                <h3>{{ comment.username }}</h3>
            </div>
            <p>{{ comment.text }}</p>
        </div>
    </div>
    <div v-else>
        <p>No comments yet. Be the first to comment!</p>
    </div>
    <div class="d-flex ">
        <input v-model="newComment" type="text" placeholder="Add a comment" class="add-comment-input my-3">
        <button @click="addComment" class="submit-button m-3">Submit</button>
    </div>
</template>

<script setup>
import { ref } from 'vue';
const comments = ref([
    {
        id: 1,
        username: 'John Doe',
        text: 'This document needs some revisions in the second paragraph.',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg'
    },
    {
        id: 2,
        username: 'Jane Smith',
        text: 'I have updated the financial figures in the report.',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg'
    },
    {
        id: 3,
        username: 'Robert Johnson',
        text: 'The final version of the document is ready for review.',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg'
    },
    {
        id: 4,
        username: 'aosmaan khikhan',
        text: 'The final version of the document is ready for review.',
        // profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg'
    },
    // Add more sample comments as needed
]);
const newComment = ref('');
const addComment = () => {
    console.log('Adding comment:', newComment.value);
}
</script>

<style lang="scss" scoped>
.profile-image {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background-size: cover;
    background-position: center;
    color: #fff;
    font-size: 20px;
    font-weight: bold;
    margin-right: 10px;
}

.comment {
    background-color: #fff;
    padding: 10px 20px;
    border-radius: 10px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 20px;
}

.comment h3 {
    font-size: 16px;
    font-weight: 600;
    color: #000;
    margin-bottom: 10px;
}

.comment p {
    font-size: 14px;
    color: #000;
}

.add-comment-input {
    width: 100%;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
    margin-bottom: 10px;
}

.comment-header {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}

.submit-button {
    background-color: #0073b1;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;

    &:hover {
        background-color: #005582;
    }
}

.user-info {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.user-info h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #000;
}

.btn {
    background-color: #007bff;
    color: #fff;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 5px;
    transition: background-color 0.3s ease;

    &:hover {
        background-color: #0056b3;
    }
}

.user-info p {
    margin: 0;
    font-size: 14px;
    color: #666;
}



.revoke-button {
    background-color: #f44336;
    color: #fff;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 5px;
}

.form-group {
    display: flex;
    flex-direction: column;
    flex-grow: 1;
    margin-right: 10px;
}

.form-group label {
    font-size: 14px;
    color: #666;
    margin-bottom: 5px;
}

.form-group input {
    padding: 5px;
    border: 1px solid #ccc;
    border-radius: 5px;
}
</style>