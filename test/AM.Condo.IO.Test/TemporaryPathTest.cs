// --------------------------------------------------------------------------------------------------------------------
// <copyright file="TemporaryPathTest.cs" company="automotiveMastermind and contributors">
//   © automotiveMastermind and contributors. Licensed under MIT. See LICENSE and CREDITS for details.
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace AM.Condo.IO
{
    using System.IO;

    using Xunit;

    [Class(nameof(TemporaryPath))]
    [Priority(1)]
    [Purpose(PurposeType.Unit)]
    public class TemporaryPathTest
    {
        [Fact]
        public void Ctor_WhenDefault_CreatesPathWithCondoPrefix()
        {
            // arrange
            // act
            var actual = new TemporaryPath();

            // assert
            Assert.NotNull(actual.FullPath);
            Assert.Contains("condo", actual.FullPath);
            Assert.True(Directory.Exists(actual.FullPath));
        }

        [Fact]
        public void Ctor_WhenPrefixNull_CreatesPathWithCondoPrefix()
        {
            // arrange
            var prefix = default(string);

            // act
            var actual = new TemporaryPath(prefix);

            // assert
            Assert.NotNull(actual.FullPath);
            Assert.Contains("condo", actual.FullPath);
            Assert.True(Directory.Exists(actual.FullPath));
        }

        [Fact]
        public void Ctor_WhenPrefixEmpty_CreatesPathWithCondoPrefix()
        {
            // arrange
            var prefix = string.Empty;

            // act
            var actual = new TemporaryPath(prefix);

            // assert
            Assert.NotNull(actual.FullPath);
            Assert.Contains("condo", actual.FullPath);
            Assert.True(Directory.Exists(actual.FullPath));
        }

        [Fact]
        public void Ctor_WhenPrefixSpecified_CreatesPathWithPrefix()
        {
            // arrange
            var prefix = "test";

            // act
            var actual = new TemporaryPath(prefix);

            // assert
            Assert.NotNull(actual.FullPath);
            Assert.Contains(prefix, actual.FullPath);
            Assert.True(Directory.Exists(actual.FullPath));
        }
    }
}
