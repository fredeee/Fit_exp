<docs>
This is a pre-built slider rating screen, with limited functionality, but simpler to use.

```vue
<Experiment>
    <SliderRangesScreen
        question="How often do you eat meat, vegetarian or vegan?"
        qud="Eating healthy is good for you."
        :ranges="['meat', 'vegetarian', 'vegan']"
    />

    <DebugResultsScreen />

</Experiment>
```
</docs>

<template>
  <!-- pass down props -->
  <LifecycleScreen v-bind="$props">
    <!-- pass down slots -->
    <template slot="fixation">
      <slot name="fixation"></slot>
    </template>
    <template slot="stimulus">
      <slot name="stimulus"></slot>
    </template>

    <template #task>
      <Record
        :data="{
          question,
          optionLeft,
          optionRight,
          interval,
          ranges,
          min,
          max
        }"
      />
      <p v-if="question" v-text="question"></p>
      <SliderRangesInput
        :left="optionLeft"
        :right="optionRight"
        :min="min"
        :max="max"
        :interval="interval"
        :ranges="ranges"
        :responses.sync="$magpie.measurements.response"
        :range-values.sync="$magpie.measurements.range_values"
      />
      <ul v-if="$magpie.measurements.range_values">
        <li v-for="(value, i) in $magpie.measurements.range_values" :key="i">
          {{ value }} {{ ranges[i] }}
        </li>
      </ul>
      <button
        v-if="
          $magpie.measurements.response &&
          !$magpie.validateMeasurements.response.$invalid
        "
        @click="nextAfterResponse"
      >
        Next
      </button>
    </template>
    <template #feedback>
      <slot name="feedback"></slot>
    </template>
  </LifecycleScreen>
</template>

<script>
import Record from '../helpers/Record';
import SliderRangesInput from '../inputs/SliderRangesInput';
import LifecycleScreen from '../screens/LifecycleScreen';

/**
 * Inherits from LifecycleScreen
 */
export default {
  name: 'SliderRangesScreen',
  components: {
    LifecycleScreen,
    SliderRangesInput,
    Record
  },
  extends: LifecycleScreen,
  props: {
    /**
     * A question
     */
    question: {
      type: String,
      required: true
    },
    /**
     * The labels for the ranges
     */
    ranges: {
      type: Array,
      required: true
    },
    /**
     * Left label for rating
     */
    optionLeft: {
      type: String,
      default: ''
    },
    /**
     * Right label for rating
     */
    optionRight: {
      type: String,
      default: ''
    },
    /**
     * Minimal slider value
     */
    min: {
      type: Number,
      optional: true,
      default: 0
    },
    /**
     * Maximum slider value
     */
    max: {
      type: Number,
      optional: true,
      default: 100
    },
    /**
     * Interval between slider values
     */
    interval: {
      type: Number,
      optional: true,
      default: 1
    }
  }
};
</script>
<style scoped></style>
