<template>
    <timeline-list title="Document Timeline">
        <timeline-item :icon="{ component: 'ni ni-bell-55', color: 'success' }" title="$2400 Design changes"
            date-time="22 DEC 7:20 PM"
            description="People care about how you see the world, how you think, what motivates you, what you’re struggling with or afraid of."
            :badges="['design']" />
        <TimelineItem :icon="{ component: 'ni ni-html5', color: 'danger' }" title="New order #1832412"
            date-time="21 DEC 11 PM"
            description="People care about how you see the world, how you think, what motivates you, what you’re struggling with or afraid of."
            :badges="['order', '#1832412']" />
        <TimelineItem :icon="{ component: 'ni ni-cart', color: 'info' }" title="Server payments for April"
            date-time="21 DEC 9:34 PM"
            description="People care about how you see the world, how you think, what motivates you, what you’re struggling with or afraid of."
            :badges="['server', 'payments']" />
    </timeline-list>
</template>

<script setup>
import TimelineList from "@/examples/Cards/TimelineList.vue";
import TimelineItem from "@/examples/Cards/TimelineItem.vue";


</script>