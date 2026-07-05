const std = @import("std");

const Evidence = struct {
    milestone: []const u8,
    path: []const u8,
};

const evidence = [_]Evidence{
    .{ .milestone = "S4-M11", .path = "compare/results/s4-m11-blocker-audit.md" },
    .{ .milestone = "S4-M12", .path = "compare/results/s4-m12-vector-profile-example.md" },
    .{ .milestone = "S4-M13", .path = "compare/results/s4-m13-lognormal-profile-example.md" },
    .{ .milestone = "S4-M14", .path = "compare/results/s4-m14-native-f32-profile-example.md" },
    .{ .milestone = "S4-M15", .path = "compare/results/s4-m15-examples-validation.md" },
    .{ .milestone = "S4-M16", .path = "compare/results/s4-m16-weighted-sampling-example.md" },
    .{ .milestone = "S4-M17", .path = "compare/results/s4-m17-multivariate-sampling-example.md" },
    .{ .milestone = "S4-M18", .path = "compare/results/s4-m18-sequence-sampling-example.md" },
    .{ .milestone = "S4-M19", .path = "compare/results/s4-m19-string-generation-example.md" },
    .{ .milestone = "S4-M20", .path = "compare/results/s4-m20-unit-geometry-example.md" },
    .{ .milestone = "S4-M21", .path = "compare/results/s4-m21-distribution-diagnostics-example.md" },
    .{ .milestone = "S4-M22", .path = "compare/results/s4-m22-reproducible-streams-example.md" },
    .{ .milestone = "S4-M23", .path = "compare/results/s4-m23-range-sampling-example.md" },
    .{ .milestone = "S4-M24", .path = "compare/results/s4-m24-discrete-distributions-example.md" },
    .{ .milestone = "S4-M25", .path = "compare/results/s4-m25-continuous-distributions-example.md" },
    .{ .milestone = "S4-M26", .path = "compare/results/s4-m26-advanced-continuous-distributions-example.md" },
    .{ .milestone = "S4-M27", .path = "compare/results/s4-m27-rank-distributions-example.md" },
    .{ .milestone = "S4-M28", .path = "compare/results/s4-m28-examples-catalog.md" },
    .{ .milestone = "S4-M29", .path = "compare/results/s4-m29-examplecheck.md" },
    .{ .milestone = "S4-M30", .path = "compare/results/s4-m30-toolingcheck.md" },
    .{ .milestone = "S4-M31", .path = "compare/results/s4-m31-readme-doccheck.md" },
    .{ .milestone = "S4-M32", .path = "compare/results/s4-m32-roadmapcheck.md" },
    .{ .milestone = "S4-M33", .path = "compare/results/s4-m33-choose-array.md" },
    .{ .milestone = "S4-M34", .path = "compare/results/s4-m34-choose-weighted.md" },
    .{ .milestone = "S4-M35", .path = "compare/results/s4-m35-reservoir-into.md" },
    .{ .milestone = "S4-M36", .path = "compare/results/s4-m36-iterator-into.md" },
    .{ .milestone = "S4-M37", .path = "compare/results/s4-m37-weighted-array.md" },
    .{ .milestone = "S4-M38", .path = "compare/results/s4-m38-weighted-index-array.md" },
    .{ .milestone = "S4-M39", .path = "compare/results/s4-m39-weighted-iterator-array.md" },
    .{ .milestone = "S4-M40", .path = "compare/results/s4-m40-iterator-array.md" },
    .{ .milestone = "S4-M41", .path = "compare/results/s4-m41-weighted-indices-into.md" },
    .{ .milestone = "S4-M42", .path = "compare/results/s4-m42-weighted-into.md" },
    .{ .milestone = "S4-M43", .path = "compare/results/s4-m43-weighted-iterator-into.md" },
    .{ .milestone = "S4-M44", .path = "compare/results/s4-m44-indices-into.md" },
    .{ .milestone = "S4-M45", .path = "compare/results/s4-m45-choose-multiple-into.md" },
    .{ .milestone = "S4-M46", .path = "compare/results/s4-m46-partial-shuffle-split.md" },
    .{ .milestone = "S4-M47", .path = "compare/results/s4-m47-u32-indices-into.md" },
    .{ .milestone = "S4-M48", .path = "compare/results/s4-m48-caller-owned-example.md" },
    .{ .milestone = "S4-M49", .path = "compare/results/s4-m49-indexvec-item-iterators.md" },
    .{ .milestone = "S4-M50", .path = "compare/results/s4-m50-indexvec-into.md" },
    .{ .milestone = "S4-M51", .path = "compare/results/s4-m51-indexvec-mutptrs.md" },
    .{ .milestone = "S4-M52", .path = "compare/results/s4-m52-choose-multiple-ptrs-into.md" },
    .{ .milestone = "S4-M53", .path = "compare/results/s4-m53-choose-ptr-array.md" },
    .{ .milestone = "S4-M54", .path = "compare/results/s4-m54-weighted-ptr-array.md" },
    .{ .milestone = "S4-M55", .path = "compare/results/s4-m55-weighted-ptrs-into.md" },
    .{ .milestone = "S4-M56", .path = "compare/results/s4-m56-choose-const-ptr.md" },
    .{ .milestone = "S4-M57", .path = "compare/results/s4-m57-choose-weighted-const-ptr.md" },
    .{ .milestone = "S4-M58", .path = "compare/results/s4-m58-choose-multiple-ptrs.md" },
    .{ .milestone = "S4-M59", .path = "compare/results/s4-m59-weighted-ptrs.md" },
    .{ .milestone = "S4-M60", .path = "compare/results/s4-m60-reservoir-ptrs.md" },
    .{ .milestone = "S4-M61", .path = "compare/results/s4-m61-reservoir-ptrs-into.md" },
    .{ .milestone = "S4-M62", .path = "compare/results/s4-m62-caller-owned-pointer-example.md" },
    .{ .milestone = "S4-M63", .path = "compare/results/s4-m63-choose-index.md" },
    .{ .milestone = "S4-M64", .path = "compare/results/s4-m64-generic-weighted-index.md" },
    .{ .milestone = "S4-M65", .path = "compare/results/s4-m65-example-output-check.md" },
    .{ .milestone = "S4-M66", .path = "compare/results/s4-m66-s4-m11-blockercheck.md" },
    .{ .milestone = "S4-M67", .path = "compare/results/s4-m67-readme-choice-discovery.md" },
    .{ .milestone = "S4-M68", .path = "compare/results/s4-m68-doccheck-dependency-check.md" },
    .{ .milestone = "S4-M69", .path = "compare/results/s4-m69-weighted-indexvec.md" },
    .{ .milestone = "S4-M70", .path = "compare/results/s4-m70-weighted-u32-indices-into.md" },
    .{ .milestone = "S4-M71", .path = "compare/results/s4-m71-weighted-u32-index-array.md" },
    .{ .milestone = "S4-M72", .path = "compare/results/s4-m72-weighted-u32-indices.md" },
    .{ .milestone = "S4-M73", .path = "compare/results/s4-m73-u32-index-array.md" },
    .{ .milestone = "S4-M74", .path = "compare/results/s4-m74-indexvec-u32-export.md" },
    .{ .milestone = "S4-M75", .path = "compare/results/s4-m75-indexvec-owned-mapping.md" },
    .{ .milestone = "S4-M76", .path = "compare/results/s4-m76-choose-index-u32.md" },
    .{ .milestone = "S4-M77", .path = "compare/results/s4-m77-generic-weighted-index-u32.md" },
    .{ .milestone = "S4-M78", .path = "compare/results/s4-m78-rng-weighted-index-u32.md" },
    .{ .milestone = "S4-M79", .path = "compare/results/s4-m79-weighted-choice-index-fills.md" },
    .{ .milestone = "S4-M80", .path = "compare/results/s4-m80-choice-index-fills.md" },
    .{ .milestone = "S4-M81", .path = "compare/results/s4-m81-choice-sample-index.md" },
    .{ .milestone = "S4-M82", .path = "compare/results/s4-m82-choice-owned-indices.md" },
    .{ .milestone = "S4-M83", .path = "compare/results/s4-m83-weighted-choice-owned-indices.md" },
    .{ .milestone = "S4-M84", .path = "compare/results/s4-m84-choice-owned-values-ptrs.md" },
    .{ .milestone = "S4-M85", .path = "compare/results/s4-m85-rng-owned-batches.md" },
    .{ .milestone = "S4-M86", .path = "compare/results/s4-m86-rng-owned-bytes.md" },
    .{ .milestone = "S4-M87", .path = "compare/results/s4-m87-rng-owned-ranges.md" },
    .{ .milestone = "S4-M88", .path = "compare/results/s4-m88-rng-owned-strict-intervals.md" },
    .{ .milestone = "S4-M89", .path = "compare/results/s4-m89-rng-owned-probabilities.md" },
    .{ .milestone = "S4-M90", .path = "compare/results/s4-m90-rng-owned-normal-exponential.md" },
    .{ .milestone = "S4-M91", .path = "compare/results/s4-m91-rng-owned-durations.md" },
    .{ .milestone = "S4-M92", .path = "compare/results/s4-m92-rng-owned-vector-ranges.md" },
    .{ .milestone = "S4-M93", .path = "compare/results/s4-m93-rng-owned-vector-strict-intervals.md" },
    .{ .milestone = "S4-M94", .path = "compare/results/s4-m94-rng-owned-vector-probabilities.md" },
    .{ .milestone = "S4-M95", .path = "compare/results/s4-m95-rng-owned-vector-normal-exponential.md" },
    .{ .milestone = "S4-M96", .path = "compare/results/s4-m96-rng-owned-standard-normal-exponential.md" },
    .{ .milestone = "S4-M97", .path = "compare/results/s4-m97-rng-owned-unicode-scalars.md" },
    .{ .milestone = "S4-M98", .path = "compare/results/s4-m98-unicode-scalar-ranges.md" },
    .{ .milestone = "S4-M99", .path = "compare/results/s4-m99-rng-owned-bounded-uint.md" },
    .{ .milestone = "S4-M100", .path = "compare/results/s4-m100-rng-owned-inclusive-ranges.md" },
    .{ .milestone = "S4-M101", .path = "compare/results/s4-m101-rng-owned-vector-inclusive-ranges.md" },
    .{ .milestone = "S4-M102", .path = "compare/results/s4-m102-rng-owned-index-choice-batches.md" },
    .{ .milestone = "S4-M103", .path = "compare/results/s4-m103-rng-owned-value-choice-batches.md" },
    .{ .milestone = "S4-M104", .path = "compare/results/s4-m104-rng-owned-const-ptr-choice-batches.md" },
    .{ .milestone = "S4-M105", .path = "compare/results/s4-m105-rng-owned-mut-ptr-choice-batches.md" },
    .{ .milestone = "S4-M106", .path = "compare/results/s4-m106-rng-owned-weighted-index-batches.md" },
    .{ .milestone = "S4-M107", .path = "compare/results/s4-m107-rng-owned-weighted-u32-index-batches.md" },
    .{ .milestone = "S4-M108", .path = "compare/results/s4-m108-rng-owned-weighted-value-batches.md" },
    .{ .milestone = "S4-M109", .path = "compare/results/s4-m109-rng-owned-weighted-const-ptr-batches.md" },
    .{ .milestone = "S4-M110", .path = "compare/results/s4-m110-rng-owned-weighted-mut-ptr-batches.md" },
    .{ .milestone = "S4-M111", .path = "compare/results/s4-m111-generic-weighted-index-batches.md" },
    .{ .milestone = "S4-M112", .path = "compare/results/s4-m112-generic-weighted-value-batches.md" },
    .{ .milestone = "S4-M113", .path = "compare/results/s4-m113-generic-weighted-const-ptr-batches.md" },
    .{ .milestone = "S4-M114", .path = "compare/results/s4-m114-generic-weighted-mut-ptr-batches.md" },
    .{ .milestone = "S4-M115", .path = "compare/results/s4-m115-accessor-weighted-choices.md" },
    .{ .milestone = "S4-M116", .path = "compare/results/s4-m116-accessor-weighted-samples.md" },
    .{ .milestone = "S4-M117", .path = "compare/results/s4-m117-accessor-weighted-into.md" },
    .{ .milestone = "S4-M118", .path = "compare/results/s4-m118-accessor-weighted-index-samples.md" },
    .{ .milestone = "S4-M119", .path = "compare/results/s4-m119-accessor-weighted-index-arrays.md" },
    .{ .milestone = "S4-M120", .path = "compare/results/s4-m120-accessor-weighted-item-arrays.md" },
    .{ .milestone = "S4-M121", .path = "compare/results/s4-m121-weightedchoice-accessor-init.md" },
    .{ .milestone = "S4-M122", .path = "compare/results/s4-m122-stable-iterator-choice.md" },
    .{ .milestone = "S4-M123", .path = "compare/results/s4-m123-iterator-sample-fill.md" },
    .{ .milestone = "S4-M124", .path = "compare/results/s4-m124-slice-sample-aliases.md" },
    .{ .milestone = "S4-M125", .path = "compare/results/s4-m125-index-weighted-samples.md" },
    .{ .milestone = "S4-M126", .path = "compare/results/s4-m126-index-weighted-into.md" },
    .{ .milestone = "S4-M127", .path = "compare/results/s4-m127-index-weighted-arrays.md" },
    .{ .milestone = "S4-M128", .path = "compare/results/s4-m128-slice-sample-array-aliases.md" },
    .{ .milestone = "S4-M129", .path = "compare/results/s4-m129-seq-shuffle-aliases.md" },
    .{ .milestone = "S4-M130", .path = "compare/results/s4-m130-tail-partial-shuffle.md" },
    .{ .milestone = "S4-M131", .path = "compare/results/s4-m131-seq-choice-aliases.md" },
    .{ .milestone = "S4-M132", .path = "compare/results/s4-m132-seq-choice-fills.md" },
    .{ .milestone = "S4-M133", .path = "compare/results/s4-m133-seq-owned-choice-batches.md" },
    .{ .milestone = "S4-M134", .path = "compare/results/s4-m134-seq-index-choice-aliases.md" },
    .{ .milestone = "S4-M135", .path = "compare/results/s4-m135-accessor-weighted-choice-fills.md" },
    .{ .milestone = "S4-M136", .path = "compare/results/s4-m136-accessor-weighted-choice-batches.md" },
    .{ .milestone = "S4-M137", .path = "compare/results/s4-m137-accessor-weighted-index-choice.md" },
    .{ .milestone = "S4-M138", .path = "compare/results/s4-m138-accessor-weighted-index-fills.md" },
    .{ .milestone = "S4-M139", .path = "compare/results/s4-m139-accessor-weighted-index-batches.md" },
    .{ .milestone = "S4-M140", .path = "compare/results/s4-m140-index-weighted-index-choice.md" },
    .{ .milestone = "S4-M141", .path = "compare/results/s4-m141-index-weighted-index-fills.md" },
    .{ .milestone = "S4-M142", .path = "compare/results/s4-m142-index-weighted-index-batches.md" },
    .{ .milestone = "S4-M143", .path = "compare/results/s4-m143-index-weighted-item-choices.md" },
    .{ .milestone = "S4-M144", .path = "compare/results/s4-m144-index-weighted-item-choice-fills.md" },
    .{ .milestone = "S4-M145", .path = "compare/results/s4-m145-index-weighted-item-choice-batches.md" },
    .{ .milestone = "S4-M146", .path = "compare/results/s4-m146-weightedchoice-index-accessor-init.md" },
    .{ .milestone = "S4-M147", .path = "compare/results/s4-m147-weighted-tree-index-accessors.md" },
    .{ .milestone = "S4-M148", .path = "compare/results/s4-m148-weighted-tree-item-accessors.md" },
    .{ .milestone = "S4-M149", .path = "compare/results/s4-m149-weighted-tree-u32-output.md" },
    .{ .milestone = "S4-M150", .path = "compare/results/s4-m150-weighted-tree-owned-indices.md" },
    .{ .milestone = "S4-M151", .path = "compare/results/s4-m151-weighted-tree-index-aliases.md" },
    .{ .milestone = "S4-M152", .path = "compare/results/s4-m152-weighted-tree-index-iterators.md" },
    .{ .milestone = "S4-M153", .path = "compare/results/s4-m153-aliastable-u32-output.md" },
    .{ .milestone = "S4-M154", .path = "compare/results/s4-m154-aliastable-owned-indices.md" },
    .{ .milestone = "S4-M155", .path = "compare/results/s4-m155-aliastable-index-aliases.md" },
    .{ .milestone = "S4-M156", .path = "compare/results/s4-m156-aliastable-index-iterators.md" },
    .{ .milestone = "S4-M157", .path = "compare/results/s4-m157-aliastable-index-accessors.md" },
    .{ .milestone = "S4-M158", .path = "compare/results/s4-m158-aliastable-item-accessors.md" },
    .{ .milestone = "S4-M159", .path = "compare/results/s4-m159-aliastable-index-arrays.md" },
    .{ .milestone = "S4-M160", .path = "compare/results/s4-m160-weighted-tree-index-arrays.md" },
    .{ .milestone = "S4-M161", .path = "compare/results/s4-m161-weightedchoice-index-arrays.md" },
    .{ .milestone = "S4-M162", .path = "compare/results/s4-m162-choice-index-arrays.md" },
    .{ .milestone = "S4-M163", .path = "compare/results/s4-m163-choice-value-ptr-arrays.md" },
    .{ .milestone = "S4-M164", .path = "compare/results/s4-m164-weightedchoice-value-ptr-arrays.md" },
    .{ .milestone = "S4-M165", .path = "compare/results/s4-m165-index-choice-arrays.md" },
    .{ .milestone = "S4-M166", .path = "compare/results/s4-m166-rng-choice-arrays.md" },
    .{ .milestone = "S4-M167", .path = "compare/results/s4-m167-rng-weighted-choice-arrays.md" },
    .{ .milestone = "S4-M168", .path = "compare/results/s4-m168-seq-generic-weighted-choice-arrays.md" },
    .{ .milestone = "S4-M169", .path = "compare/results/s4-m169-accessor-weighted-choice-arrays.md" },
    .{ .milestone = "S4-M170", .path = "compare/results/s4-m170-index-weighted-choice-arrays.md" },
    .{ .milestone = "S4-M171", .path = "compare/results/s4-m171-seq-repeated-choice-arrays.md" },
    .{ .milestone = "S4-M172", .path = "compare/results/s4-m172-choice-index-iterators.md" },
    .{ .milestone = "S4-M173", .path = "compare/results/s4-m173-indexvec-consuming-owned.md" },
    .{ .milestone = "S4-M174", .path = "compare/results/s4-m174-indexvec-equality.md" },
    .{ .milestone = "S4-M175", .path = "compare/results/s4-m175-indexvec-owned-constructors.md" },
    .{ .milestone = "S4-M176", .path = "compare/results/s4-m176-indexvec-clone.md" },
    .{ .milestone = "S4-M177", .path = "compare/results/s4-m177-indexvec-consuming-iterator.md" },
    .{ .milestone = "S4-M178", .path = "compare/results/s4-m178-weighted-choice-iterators.md" },
    .{ .milestone = "S4-M179", .path = "compare/results/s4-m179-accessor-weighted-choice-iterators.md" },
    .{ .milestone = "S4-M180", .path = "compare/results/s4-m180-index-weighted-choice-iterators.md" },
    .{ .milestone = "S4-M181", .path = "compare/results/s4-m181-sampled-ptr-iterators.md" },
    .{ .milestone = "S4-M182", .path = "compare/results/s4-m182-sampled-value-iterators.md" },
    .{ .milestone = "S4-M183", .path = "compare/results/s4-m183-sampled-mut-ptr-iterators.md" },
    .{ .milestone = "S4-M184", .path = "compare/results/s4-m184-choice-numchoices.md" },
    .{ .milestone = "S4-M185", .path = "compare/results/s4-m185-sampled-iterator-fill.md" },
    .{ .milestone = "S4-M186", .path = "compare/results/s4-m186-iterator-len-aliases.md" },
    .{ .milestone = "S4-M187", .path = "compare/results/s4-m187-iterator-size-hints.md" },
    .{ .milestone = "S4-M188", .path = "compare/results/s4-m188-indexvec-iterator-fill.md" },
    .{ .milestone = "S4-M189", .path = "compare/results/s4-m189-indexvec-index-alias.md" },
    .{ .milestone = "S4-M190", .path = "compare/results/s4-m190-indexvec-get.md" },
    .{ .milestone = "S4-M191", .path = "compare/results/s4-m191-weighted-sampler-weight.md" },
    .{ .milestone = "S4-M192", .path = "compare/results/s4-m192-weight-iterators.md" },
    .{ .milestone = "S4-M193", .path = "compare/results/s4-m193-weighted-sampler-probability.md" },
    .{ .milestone = "S4-M194", .path = "compare/results/s4-m194-probability-iterators.md" },
    .{ .milestone = "S4-M195", .path = "compare/results/s4-m195-choice-probability.md" },
    .{ .milestone = "S4-M196", .path = "compare/results/s4-m196-choice-probability-iterator.md" },
    .{ .milestone = "S4-M197", .path = "compare/results/s4-m197-charset-probability.md" },
    .{ .milestone = "S4-M198", .path = "compare/results/s4-m198-charset-probability-iterator.md" },
    .{ .milestone = "S4-M199", .path = "compare/results/s4-m199-choice-get.md" },
    .{ .milestone = "S4-M200", .path = "compare/results/s4-m200-charset-get.md" },
    .{ .milestone = "S4-M201", .path = "compare/results/s4-m201-diagnostic-iterator-sizehints.md" },
    .{ .milestone = "S4-M202", .path = "compare/results/s4-m202-charset-numchoices.md" },
    .{ .milestone = "S4-M203", .path = "compare/results/s4-m203-choice-item-alias.md" },
    .{ .milestone = "S4-M204", .path = "compare/results/s4-m204-charset-item-alias.md" },
    .{ .milestone = "S4-M205", .path = "compare/results/s4-m205-tree-weight.md" },
    .{ .milestone = "S4-M206", .path = "compare/results/s4-m206-tree-probability.md" },
    .{ .milestone = "S4-M207", .path = "compare/results/s4-m207-tree-weight-iterators.md" },
    .{ .milestone = "S4-M208", .path = "compare/results/s4-m208-tree-probability-iterators.md" },
    .{ .milestone = "S4-M209", .path = "compare/results/s4-m209-aliastable-numchoices.md" },
    .{ .milestone = "S4-M210", .path = "compare/results/s4-m210-tree-numchoices.md" },
    .{ .milestone = "S4-M211", .path = "compare/results/s4-m211-tree-constant-index.md" },
    .{ .milestone = "S4-M212", .path = "compare/results/s4-m212-weightedchoice-constant-index.md" },
    .{ .milestone = "S4-M213", .path = "compare/results/s4-m213-choice-constant-index.md" },
    .{ .milestone = "S4-M214", .path = "compare/results/s4-m214-charset-constant-index.md" },
    .{ .milestone = "S4-M215", .path = "compare/results/s4-m215-tree-positive-count.md" },
    .{ .milestone = "S4-M216", .path = "compare/results/s4-m216-aliastable-positive-count.md" },
    .{ .milestone = "S4-M217", .path = "compare/results/s4-m217-weightedchoice-positive-count.md" },
    .{ .milestone = "S4-M218", .path = "compare/results/s4-m218-weighted-update-at.md" },
    .{ .milestone = "S4-M219", .path = "compare/results/s4-m219-weighted-update-many.md" },
    .{ .milestone = "S4-M220", .path = "compare/results/s4-m220-tree-update-many.md" },
    .{ .milestone = "S4-M221", .path = "compare/results/s4-m221-weighted-updateweights-alias.md" },
    .{ .milestone = "S4-M222", .path = "compare/results/s4-m222-indexvec-into-vec.md" },
    .{ .milestone = "S4-M223", .path = "compare/results/s4-m223-choice-new-alias.md" },
    .{ .milestone = "S4-M224", .path = "compare/results/s4-m224-weighted-new-alias.md" },
    .{ .milestone = "S4-M225", .path = "compare/results/s4-m225-bernoulli-new-alias.md" },
    .{ .milestone = "S4-M226", .path = "compare/results/s4-m226-uniform-new-alias.md" },
    .{ .milestone = "S4-M227", .path = "compare/results/s4-m227-bernoulli-fromratio-alias.md" },
    .{ .milestone = "S4-M228", .path = "compare/results/s4-m228-bernoulli-p-alias.md" },
    .{ .milestone = "S4-M229", .path = "compare/results/s4-m229-uniform-samplesingle-alias.md" },
    .{ .milestone = "S4-M230", .path = "compare/results/s4-m230-rng-random-bool-ratio-alias.md" },
    .{ .milestone = "S4-M231", .path = "compare/results/s4-m231-rng-random-range-alias.md" },
    .{ .milestone = "S4-M232", .path = "compare/results/s4-m232-rng-sample-alias.md" },
    .{ .milestone = "S4-M233", .path = "compare/results/s4-m233-rng-random-value-alias.md" },
    .{ .milestone = "S4-M234", .path = "compare/results/s4-m234-rng-raw-aliases.md" },
    .{ .milestone = "S4-M235", .path = "compare/results/s4-m235-engine-raw-aliases.md" },
    .{ .milestone = "S4-M236", .path = "compare/results/s4-m236-engine-seedfromu64-aliases.md" },
    .{ .milestone = "S4-M237", .path = "compare/results/s4-m237-engine-fromseed-aliases.md" },
    .{ .milestone = "S4-M238", .path = "compare/results/s4-m238-engine-fromrng-fork-aliases.md" },
    .{ .milestone = "S4-M239", .path = "compare/results/s4-m239-full-state-fromrng.md" },
    .{ .milestone = "S4-M240", .path = "compare/results/s4-m240-engine-fromseedbytes-aliases.md" },
    .{ .milestone = "S4-M241", .path = "compare/results/s4-m241-engine-tryfromrng-aliases.md" },
    .{ .milestone = "S4-M242", .path = "compare/results/s4-m242-engine-tryfork-aliases.md" },
    .{ .milestone = "S4-M243", .path = "compare/results/s4-m243-try-raw-rng-aliases.md" },
    .{ .milestone = "S4-M244", .path = "compare/results/s4-m244-rng-try-raw-from-aliases.md" },
    .{ .milestone = "S4-M245", .path = "compare/results/s4-m245-root-makerng.md" },
    .{ .milestone = "S4-M246", .path = "compare/results/s4-m246-rng-reader.md" },
    .{ .milestone = "S4-M247", .path = "compare/results/s4-m247-sysrng.md" },
    .{ .milestone = "S4-M248", .path = "compare/results/s4-m248-mapped-sampler.md" },
    .{ .milestone = "S4-M249", .path = "compare/results/s4-m249-unbounded-iterator-sizehint.md" },
    .{ .milestone = "S4-M250", .path = "compare/results/s4-m250-distribution-sampleiter.md" },
    .{ .milestone = "S4-M251", .path = "compare/results/s4-m251-samplestring-aliases.md" },
    .{ .milestone = "S4-M252", .path = "compare/results/s4-m252-unicode-charset.md" },
    .{ .milestone = "S4-M253", .path = "compare/results/s4-m253-hinted-iterator-choice.md" },
    .{ .milestone = "S4-M254", .path = "compare/results/s4-m254-stdrng-smallrng-aliases.md" },
    .{ .milestone = "S4-M255", .path = "compare/results/s4-m255-step-rng.md" },
    .{ .milestone = "S4-M256", .path = "compare/results/s4-m256-chacha12rng-alias.md" },
    .{ .milestone = "S4-M257", .path = "compare/results/s4-m257-chacha8-chacha20-rngs.md" },
    .{ .milestone = "S4-M258", .path = "compare/results/s4-m258-xoshiro128plusplus.md" },
    .{ .milestone = "S4-M259", .path = "compare/results/s4-m259-root-random-helpers.md" },
    .{ .milestone = "S4-M260", .path = "compare/results/s4-m260-syserror-alias.md" },
    .{ .milestone = "S4-M261", .path = "compare/results/s4-m261-weighterror-alias.md" },
    .{ .milestone = "S4-M262", .path = "compare/results/s4-m262-standard-uniform.md" },
};

const required_tokens = [_][]const u8{
    "Active Goal Completion Audit",
    "S4-M11",
    "blocked",
    "do not call `update_goal(status=complete)`",
    "S4-M263",
    "No proxy signal is accepted as whole-goal completion",
};

const blocker_tokens = [_][]const u8{
    "exact/default-compatible dense SIMD",
    "qemu-aarch64",
    "qemu-riscv64",
    "wine",
    "wasmtime",
    "wasmer",
    "no SIMD non-uniform implementation",
    "Do not call `update_goal(status=complete)`",
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var stderr_buffer: [2048]u8 = undefined;
    var stderr_file = std.Io.File.stderr().writer(io, &stderr_buffer);
    const stderr = &stderr_file.interface;

    const allocator = std.heap.smp_allocator;
    const roadmap = try readFile(io, allocator, "compare/results/core-rand-coverage.md");
    defer allocator.free(roadmap);
    const audit = try readFile(io, allocator, "compare/results/active-goal-completion-audit.md");
    defer allocator.free(audit);
    const linux_audit = try readFile(io, allocator, "compare/results/linux-no-known-gaps-audit.md");
    defer allocator.free(linux_audit);
    const tooling = try readFile(io, allocator, "docs/tooling.md");
    defer allocator.free(tooling);
    const readme = try readFile(io, allocator, "README.md");
    defer allocator.free(readme);
    const build = try readFile(io, allocator, "build.zig");
    defer allocator.free(build);
    const blocker = try readFile(io, allocator, "compare/results/s4-m11-blocker-audit.md");
    defer allocator.free(blocker);

    var missing: usize = 0;

    inline for (evidence) |item| {
        std.Io.Dir.cwd().access(io, item.path, .{}) catch |err| {
            try stderr.print("roadmapcheck: missing evidence file {s}: {s}\n", .{ item.path, @errorName(err) });
            missing += 1;
            return;
        };
        if (std.mem.indexOf(u8, roadmap, item.milestone) == null or
            std.mem.indexOf(u8, roadmap, item.path) == null)
        {
            try stderr.print("roadmapcheck: core-rand-coverage.md missing `{s}` / `{s}`\n", .{ item.milestone, item.path });
            missing += 1;
        }
        if (std.mem.indexOf(u8, audit, item.milestone) == null) {
            try stderr.print("roadmapcheck: active-goal-completion-audit.md missing `{s}`\n", .{item.milestone});
            missing += 1;
        }
        if (!std.mem.eql(u8, item.milestone, "S4-M11") and
            std.mem.indexOf(u8, linux_audit, item.path) == null)
        {
            try stderr.print("roadmapcheck: linux-no-known-gaps-audit.md missing `{s}`\n", .{item.path});
            missing += 1;
        }
    }

    inline for (required_tokens) |token| {
        if (std.mem.indexOf(u8, audit, token) == null and std.mem.indexOf(u8, roadmap, token) == null) {
            try stderr.print("roadmapcheck: roadmap/audit missing required token `{s}`\n", .{token});
            missing += 1;
        }
    }

    inline for (blocker_tokens) |token| {
        if (std.mem.indexOf(u8, blocker, token) == null) {
            try stderr.print("roadmapcheck: s4-m11-blocker-audit.md missing blocker token `{s}`\n", .{token});
            missing += 1;
        }
    }

    if (std.mem.indexOf(u8, roadmap, "| S4-M263 | Next unblocked product gap") == null) {
        try stderr.print("roadmapcheck: core-rand-coverage.md missing S4-M263 next-gap row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "| S4-M263 next unblocked product gap") == null) {
        try stderr.print("roadmapcheck: active audit missing S4-M263 next-gap row\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, audit, "S4-M11 remains unresolved") == null) {
        try stderr.print("roadmapcheck: active audit must keep S4-M11 unresolved statement\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, build, "doccheck_step.dependOn(&run_roadmapcheck.step)") == null) {
        try stderr.print("roadmapcheck: doccheck must depend on roadmapcheck\n", .{});
        missing += 1;
    }
    if (std.mem.indexOf(u8, tooling, "zig build roadmapcheck") == null or
        std.mem.indexOf(u8, readme, "zig build roadmapcheck") == null)
    {
        try stderr.print("roadmapcheck: README.md and docs/tooling.md must mention `zig build roadmapcheck`\n", .{});
        missing += 1;
    }

    if (missing != 0) {
        try stderr.flush();
        return error.RoadmapAuditIncomplete;
    }

    try stdout.print("roadmapcheck ok\n", .{});
    try stdout.flush();
}

fn readFile(io: std.Io, allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    return std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(8 * 1024 * 1024));
}
