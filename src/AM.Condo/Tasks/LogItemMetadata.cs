// --------------------------------------------------------------------------------------------------------------------
// <copyright file="LogItemMetadata.cs" company="automotiveMastermind and contributors">
// © automotiveMastermind and contributors. Licensed under MIT. See LICENSE and CREDITS for details.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace AM.Condo.Tasks
{
    using System.Linq;
    using Microsoft.Build.Framework;
    using Microsoft.Build.Utilities;

    /// <summary>
    /// Represents a Microsoft Build task that logs all metadata associated with one or more items.
    /// </summary>
    public class LogItemMetadata : Task
    {
        #region Properties and Indexers
        /// <summary>
        /// Gets or sets the collection of items for which to log associated metadata.
        /// </summary>
        [Required]
        public ITaskItem[] Items { get; set; }

        /// <summary>
        /// Gets or sets the name of the specification when printing an item.
        /// </summary>
        public string Name { get; set; } = "Item";
        #endregion

        #region Methods
        /// <summary>
        /// Executes the <see cref="LogItemMetadata"/> task.
        /// </summary>
        /// <returns>
        /// A value indicating whether or not the task was successfully executed.
        /// </returns>
        public override bool Execute()
        {
            // iterate over each item
            foreach (var item in this.Items)
            {
                // log the item specification
                this.Log.LogMessage(MessageImportance.High, "{0,-19}: {1}", this.Name, item.ItemSpec);

                // iterate over each metdata name
                foreach (var name in item.MetadataNames.Cast<string>())
                {
                    // get the value for the metadata
                    var value = item.GetMetadata(name);

                    // log the name of the metdata and its associated value
                    this.Log.LogMessage(MessageImportance.Low, "  {0,-17}: {1}", name, value);
                }
            }

            // should always succeed
            return true;
        }
        #endregion
    }
}
